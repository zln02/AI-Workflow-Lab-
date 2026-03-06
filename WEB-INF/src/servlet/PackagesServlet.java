package servlet;

import dao.PackageDAO;
import model.Package;
import dto.ApiResponse;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * 패키지 API 서블릿
 * /api/packages/* 경로로 들어오는 요청 처리
 */
@WebServlet("/api/packages/*")
public class PackagesServlet extends HttpServlet {
    private PackageDAO packageDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        packageDAO = new PackageDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String pathInfo = request.getPathInfo();
            
            if (pathInfo == null || pathInfo.equals("/")) {
                // 전체 패키지 목록
                int page = 1;
                int pageSize = 20;
                
                try {
                    String pageStr = request.getParameter("page");
                    String pageSizeStr = request.getParameter("pageSize");
                    
                    if (pageStr != null) page = Integer.parseInt(pageStr);
                    if (pageSizeStr != null) pageSize = Integer.parseInt(pageSizeStr);
                    
                    if (page < 1) page = 1;
                    if (pageSize < 1 || pageSize > 100) pageSize = 20;
                } catch (NumberFormatException e) {
                    // 기본값 사용
                }
                
                List<Package> packages = packageDAO.getAllPackages(page, pageSize);
                ApiResponse<List<Package>> apiResponse = ApiResponse.success(packages);
                out.print(gson.toJson(apiResponse));
                
            } else if (pathInfo.startsWith("/")) {
                // 특정 패키지 정보
                try {
                    int packageId = Integer.parseInt(pathInfo.substring(1));
                    Package pkg = packageDAO.getPackageById(packageId);
                    
                    if (pkg != null) {
                        ApiResponse<Package> apiResponse = ApiResponse.success(pkg);
                        out.print(gson.toJson(apiResponse));
                    } else {
                        ApiResponse<Object> apiResponse = ApiResponse.notFound("패키지를 찾을 수 없습니다.");
                        response.setStatus(404);
                        out.print(gson.toJson(apiResponse));
                    }
                } catch (NumberFormatException e) {
                    ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 패키지 ID 형식입니다.");
                    response.setStatus(400);
                    out.print(gson.toJson(apiResponse));
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            ApiResponse<Object> apiResponse = ApiResponse.error("서버 오류가 발생했습니다.");
            response.setStatus(500);
            out.print(gson.toJson(apiResponse));
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // 패키지 생성 로직
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            Double price = null;
            Double discountPrice = null;
            
            try {
                String priceStr = request.getParameter("price");
                String discountPriceStr = request.getParameter("discountPrice");
                
                if (priceStr != null) price = Double.parseDouble(priceStr);
                if (discountPriceStr != null) discountPrice = Double.parseDouble(discountPriceStr);
            } catch (NumberFormatException e) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 가격 형식입니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            if (title == null || description == null || price == null) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("필수 파라미터가 누락되었습니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            // 패키지 생성
            Package newPackage = new Package();
            newPackage.setTitle(title);
            newPackage.setDescription(description);
            newPackage.setPrice(java.math.BigDecimal.valueOf(price));
            if (discountPrice != null) {
                newPackage.setDiscountPrice(java.math.BigDecimal.valueOf(discountPrice));
            }
            newPackage.setActive(true);
            
            boolean created = packageDAO.addPackage(newPackage);
            
            if (created) {
                ApiResponse<Package> apiResponse = ApiResponse.success("패키지가 생성되었습니다.", newPackage);
                response.setStatus(201);
                out.print(gson.toJson(apiResponse));
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("패키지 생성에 실패했습니다.");
                response.setStatus(500);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            ApiResponse<Object> apiResponse = ApiResponse.error("서버 오류가 발생했습니다.");
            response.setStatus(500);
            out.print(gson.toJson(apiResponse));
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String pathInfo = request.getPathInfo();
            
            if (pathInfo == null || !pathInfo.startsWith("/")) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 요청 경로입니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            int packageId = Integer.parseInt(pathInfo.substring(1));
            Package pkg = packageDAO.getPackageById(packageId);
            
            if (pkg == null) {
                ApiResponse<Object> apiResponse = ApiResponse.notFound("패키지를 찾을 수 없습니다.");
                response.setStatus(404);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            // 패키지 정보 업데이트
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String status = request.getParameter("status");
            
            if (title != null) pkg.setTitle(title);
            if (description != null) pkg.setDescription(description);
            if (status != null) pkg.setActive("active".equalsIgnoreCase(status));
            
            try {
                String priceStr = request.getParameter("price");
                String discountPriceStr = request.getParameter("discountPrice");
                
                if (priceStr != null) {
                    pkg.setPrice(java.math.BigDecimal.valueOf(Double.parseDouble(priceStr)));
                }
                if (discountPriceStr != null) {
                    pkg.setDiscountPrice(java.math.BigDecimal.valueOf(Double.parseDouble(discountPriceStr)));
                }
            } catch (NumberFormatException e) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 가격 형식입니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            boolean updated = packageDAO.updatePackage(pkg);
            
            if (updated) {
                ApiResponse<Package> apiResponse = ApiResponse.success("패키지 정보가 업데이트되었습니다.", pkg);
                out.print(gson.toJson(apiResponse));
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("패키지 정보 업데이트에 실패했습니다.");
                response.setStatus(500);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (NumberFormatException e) {
            ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 패키지 ID 형식입니다.");
            response.setStatus(400);
            out.print(gson.toJson(apiResponse));
        } catch (Exception e) {
            e.printStackTrace();
            ApiResponse<Object> apiResponse = ApiResponse.error("서버 오류가 발생했습니다.");
            response.setStatus(500);
            out.print(gson.toJson(apiResponse));
        }
    }
    
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String pathInfo = request.getPathInfo();
            
            if (pathInfo == null || !pathInfo.startsWith("/")) {
                ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 요청 경로입니다.");
                response.setStatus(400);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            int packageId = Integer.parseInt(pathInfo.substring(1));
            Package pkg = packageDAO.getPackageById(packageId);
            
            if (pkg == null) {
                ApiResponse<Object> apiResponse = ApiResponse.notFound("패키지를 찾을 수 없습니다.");
                response.setStatus(404);
                out.print(gson.toJson(apiResponse));
                return;
            }
            
            boolean deleted = packageDAO.deletePackage(packageId);
            
            if (deleted) {
                ApiResponse<Object> apiResponse = ApiResponse.success("패키지가 삭제되었습니다.", null);
                out.print(gson.toJson(apiResponse));
            } else {
                ApiResponse<Object> apiResponse = ApiResponse.error("패키지 삭제에 실패했습니다.");
                response.setStatus(500);
                out.print(gson.toJson(apiResponse));
            }
            
        } catch (NumberFormatException e) {
            ApiResponse<Object> apiResponse = ApiResponse.badRequest("잘못된 패키지 ID 형식입니다.");
            response.setStatus(400);
            out.print(gson.toJson(apiResponse));
        } catch (Exception e) {
            e.printStackTrace();
            ApiResponse<Object> apiResponse = ApiResponse.error("서버 오류가 발생했습니다.");
            response.setStatus(500);
            out.print(gson.toJson(apiResponse));
        }
    }
}
