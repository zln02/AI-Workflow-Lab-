package servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.CreditDAO;
import dao.CreditPackageDAO;
import dao.OrderDAO;
import dao.PlanDAO;
import dao.SubscriptionDAO;
import model.CreditPackage;
import model.Order;
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
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet("/api/payments/*")
public class PaymentServlet extends HttpServlet {
    private PlanDAO planDAO;
    private CreditPackageDAO creditPackageDAO;
    private OrderDAO orderDAO;
    private SubscriptionDAO subscriptionDAO;
    private CreditDAO creditDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        planDAO = new PlanDAO();
        creditPackageDAO = new CreditPackageDAO();
        orderDAO = new OrderDAO();
        subscriptionDAO = new SubscriptionDAO();
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
            if (pathInfo == null || "/history".equals(pathInfo) || "/".equals(pathInfo)) {
                List<Order> orders = orderDAO.findByEmail(user.getEmail());
                out.print(gson.toJson(new SuccessResponse(orders)));
                return;
            }

            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print(gson.toJson(new ErrorResponse("Not Found", "Invalid payment endpoint")));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "결제 정보를 불러오지 못했습니다.")));
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
            if ("/prepare".equals(pathInfo)) {
                handlePrepare(request, out);
                return;
            }
            if ("/complete".equals(pathInfo)) {
                handleComplete(request, user, out);
                return;
            }
            if ("/cancel".equals(pathInfo)) {
                handleCancel(request, out);
                return;
            }

            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print(gson.toJson(new ErrorResponse("Not Found", "Invalid payment endpoint")));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(new ErrorResponse("Internal Server Error", "결제 처리 중 오류가 발생했습니다.")));
        } finally {
            out.close();
        }
    }

    private void handlePrepare(HttpServletRequest request, PrintWriter out) throws Exception {
        String billingCycle = defaultString(request.getParameter("billingCycle"), "monthly");
        Plan plan = resolvePlan(request);
        CreditPackage creditPackage = resolveCreditPackage(request);

        if (plan == null && creditPackage == null) {
            out.print(gson.toJson(new ErrorResponse("Bad Request", "planId, planCode 또는 packageId가 필요합니다.")));
            return;
        }

        Map<String, Object> data = new HashMap<>();
        data.put("merchantUid", "order_" + UUID.randomUUID().toString().replace("-", ""));
        data.put("billingCycle", billingCycle);
        data.put("provider", "portone");
        data.put("impCode", System.getenv("PORTONE_IMP_CODE"));

        if (plan != null) {
            BigDecimal amount = "yearly".equalsIgnoreCase(billingCycle) && plan.getPriceYearly() != null
                    ? plan.getPriceYearly() : plan.getPriceUsd();
            data.put("itemType", "plan");
            data.put("planCode", plan.getPlanCode());
            data.put("planName", plan.getNameKo() != null ? plan.getNameKo() : plan.getName());
            data.put("amount", amount);
            data.put("credits", plan.getCreditsMonthly());
        } else {
            data.put("itemType", "credit_package");
            data.put("packageId", creditPackage.getId());
            data.put("packageName", creditPackage.getPackageName());
            data.put("amount", creditPackage.getPrice());
            data.put("credits", creditPackage.getCredits() + creditPackage.getBonusCredits());
        }

        out.print(gson.toJson(new SuccessResponse(data)));
    }

    private void handleComplete(HttpServletRequest request, User user, PrintWriter out) throws Exception {
        String paymentMethod = defaultString(request.getParameter("paymentMethod"), "card");
        String merchantUid = defaultString(request.getParameter("merchantUid"), "order_" + System.currentTimeMillis());
        String billingCycle = defaultString(request.getParameter("billingCycle"), "monthly");
        String impUid = request.getParameter("impUid");

        Plan plan = resolvePlan(request);
        CreditPackage creditPackage = resolveCreditPackage(request);
        if (plan == null && creditPackage == null) {
            out.print(gson.toJson(new ErrorResponse("Bad Request", "결제 대상이 없습니다.")));
            return;
        }

        BigDecimal amount;
        String orderStatus = "COMPLETED";
        Order order = new Order();
        order.setCustomerName(user.getFullName() != null ? user.getFullName() : user.getUsername());
        order.setCustomerEmail(user.getEmail());
        order.setPaymentMethod(paymentMethod);
        order.setOrderStatus(orderStatus);

        Map<String, Object> responseData = new HashMap<>();
        if (plan != null) {
            amount = "yearly".equalsIgnoreCase(billingCycle) && plan.getPriceYearly() != null
                    ? plan.getPriceYearly() : plan.getPriceUsd();
            order.setTotalPrice(amount);
            int orderId = orderDAO.insertOrder(order);

            Subscription active = subscriptionDAO.findActiveByUserId(user.getId());
            if (active != null) {
                subscriptionDAO.cancelActiveByUserId(user.getId());
            }

            Subscription subscription = new Subscription();
            subscription.setUserId(user.getId());
            subscription.setPlanId(plan.getId());
            subscription.setPlanCode(plan.getPlanCode());
            subscription.setStartDate(LocalDate.now());
            subscription.setBillingCycle(billingCycle);
            subscription.setEndDate(LocalDate.now().plusMonths("yearly".equalsIgnoreCase(billingCycle) ? 12 : plan.getDurationMonths()));
            subscription.setNextBillingDate(subscription.getEndDate());
            subscription.setStatus("ACTIVE");
            subscription.setPaymentMethod(paymentMethod);
            subscription.setTransactionId(impUid != null && !impUid.isEmpty() ? impUid : merchantUid);
            subscription.setLastPaymentId(orderId);
            long subscriptionId = subscriptionDAO.insert(subscription);

            if (plan.getCreditsMonthly() > 0) {
                creditDAO.grant(user.getId(), plan.getCreditsMonthly(), plan.getPlanCode());
            }

            responseData.put("orderId", orderId);
            responseData.put("subscriptionId", subscriptionId);
            responseData.put("planCode", plan.getPlanCode());
        } else {
            amount = creditPackage.getPrice();
            order.setTotalPrice(amount);
            int orderId = orderDAO.insertOrder(order);
            orderDAO.insertOrderItem(orderId, "PACKAGE", creditPackage.getId(), 1, amount);
            creditDAO.grant(user.getId(), creditPackage.getCredits() + creditPackage.getBonusCredits(), "credit_package_" + creditPackage.getId());
            responseData.put("orderId", orderId);
            responseData.put("packageId", creditPackage.getId());
            responseData.put("grantedCredits", creditPackage.getCredits() + creditPackage.getBonusCredits());
        }

        responseData.put("merchantUid", merchantUid);
        responseData.put("amount", amount);
        responseData.put("status", orderStatus);
        out.print(gson.toJson(new SuccessResponse(responseData)));
    }

    private void handleCancel(HttpServletRequest request, PrintWriter out) throws Exception {
        int orderId = parseInt(request.getParameter("orderId"), 0);
        if (orderId <= 0) {
            out.print(gson.toJson(new ErrorResponse("Bad Request", "orderId가 필요합니다.")));
            return;
        }
        boolean deleted = orderDAO.delete(orderId);
        out.print(gson.toJson(new SuccessResponse(deleted)));
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

    private Plan resolvePlan(HttpServletRequest request) throws Exception {
        String planCode = request.getParameter("planCode");
        if (planCode == null || planCode.trim().isEmpty()) {
            planCode = request.getParameter("plan");
        }
        if (planCode != null && !planCode.trim().isEmpty()) {
            return planDAO.findByCode(planCode);
        }

        int planId = parseInt(request.getParameter("planId"), 0);
        if (planId > 0) {
            for (Plan item : planDAO.findAllActive()) {
                if (item.getId() == planId) {
                    return item;
                }
            }
        }
        return null;
    }

    private CreditPackage resolveCreditPackage(HttpServletRequest request) throws Exception {
        int packageId = parseInt(request.getParameter("packageId"), 0);
        if (packageId > 0) {
            return creditPackageDAO.findById(packageId);
        }
        return null;
    }

    private int parseInt(String value, int fallback) {
        try {
            return value == null || value.trim().isEmpty() ? fallback : Integer.parseInt(value.trim());
        } catch (Exception ignored) {
            return fallback;
        }
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
