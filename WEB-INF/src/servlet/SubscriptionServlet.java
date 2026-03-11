package servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.CreditDAO;
import dao.PlanDAO;
import dao.SubscriptionDAO;
import model.Plan;
import model.Subscription;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/subscriptions/*")
public class SubscriptionServlet extends HttpServlet {
    private SubscriptionDAO subscriptionDAO;
    private PlanDAO planDAO;
    private CreditDAO creditDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        subscriptionDAO = new SubscriptionDAO();
        planDAO = new PlanDAO();
        creditDAO = new CreditDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            User user = requireUser(request, response, out);
            if (user == null) {
                return;
            }

            String pathInfo = request.getPathInfo();
            if (pathInfo == null || "/current".equals(pathInfo) || "/".equals(pathInfo)) {
                Subscription current = subscriptionDAO.findActiveByUserId(user.getId());
                if (current == null) {
                    out.print(gson.toJson(new SuccessResponse(null)));
                    return;
                }
                Map<String, Object> data = new HashMap<>();
                data.put("subscription", current);
                data.put("plan", planDAO.findByCode(current.getPlanCode()));
                out.print(gson.toJson(new SuccessResponse(data)));
                return;
            }

            if ("/usage".equals(pathInfo)) {
                Map<String, Object> usage = new HashMap<>();
                usage.put("balance", creditDAO.getBalance(user.getId()));
                usage.put("totalGranted", creditDAO.getTotalGranted(user.getId()));
                usage.put("totalUsed", creditDAO.getTotalUsed(user.getId()));
                usage.put("logs", creditDAO.getUsageLogs(user.getId(), 20));
                out.print(gson.toJson(new SuccessResponse(usage)));
                return;
            }

            if ("/history".equals(pathInfo)) {
                List<Subscription> items = subscriptionDAO.findAllByUserId(user.getId());
                out.print(gson.toJson(new SuccessResponse(items)));
                return;
            }

            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print(gson.toJson(new ErrorResponse("Not Found", "Invalid subscription endpoint")));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "구독 정보를 불러오지 못했습니다.")));
        } finally {
            out.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            User user = requireUser(request, response, out);
            if (user == null) {
                return;
            }

            String pathInfo = request.getPathInfo();
            if ("/change".equals(pathInfo)) {
                String planCode = request.getParameter("planCode");
                String billingCycle = defaultString(request.getParameter("billingCycle"), "monthly");
                Plan plan = planDAO.findByCode(planCode);
                if (plan == null) {
                    out.print(gson.toJson(new ErrorResponse("Bad Request", "유효한 planCode가 필요합니다.")));
                    return;
                }
                boolean changed = subscriptionDAO.changePlan(user.getId(), plan.getId(), plan.getPlanCode(), billingCycle);
                out.print(gson.toJson(new SuccessResponse(changed)));
                return;
            }

            if ("/cancel".equals(pathInfo)) {
                boolean canceled = subscriptionDAO.cancelActiveByUserId(user.getId());
                out.print(gson.toJson(new SuccessResponse(canceled)));
                return;
            }

            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print(gson.toJson(new ErrorResponse("Not Found", "Invalid subscription endpoint")));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "구독 요청을 처리하지 못했습니다.")));
        } finally {
            out.close();
        }
    }

    private User requireUser(HttpServletRequest request, HttpServletResponse response, PrintWriter out) {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print(gson.toJson(new ErrorResponse("Unauthorized", "로그인이 필요합니다.")));
            return null;
        }
        return user;
    }

    private String defaultString(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }

    private static class SuccessResponse {
        private final boolean success = true;
        private final Object data;

        private SuccessResponse(Object data) {
            this.data = data;
        }
    }

    private static class ErrorResponse {
        private final boolean success = false;
        private final String error;
        private final String message;

        private ErrorResponse(String error, String message) {
            this.error = error;
            this.message = message;
        }
    }
}
