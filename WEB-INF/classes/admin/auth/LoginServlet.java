package admin.auth;

import dao.AdminDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Admin;
import security.PasswordUtils;

import java.io.IOException;

public class LoginServlet extends HttpServlet {
  private static final String ADMIN_ATTR = "admin";
  private final AdminDAO adminDAO = new AdminDAO();

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    req.getRequestDispatcher("/AI/admin/auth/login.jsp").forward(req, resp);
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    req.setCharacterEncoding("UTF-8");
    String username = req.getParameter("username");
    String password = req.getParameter("password");
    String context = req.getContextPath();

    if (username == null || password == null || username.isBlank() || password.isBlank()) {
      resp.sendRedirect("/AI/admin/auth/login.jsp?error=validation");
      return;
    }

    Admin admin = adminDAO.findByUsername(username);
    if (admin == null || !PasswordUtils.matches(password, admin.getPassword())) {
      resp.sendRedirect("/AI/admin/auth/login.jsp?error=credentials");
      return;
    }
    if (!"ACTIVE".equalsIgnoreCase(admin.getStatus())) {
      resp.sendRedirect("/AI/admin/auth/login.jsp?error=status");
      return;
    }

    // 마지막 로그인 시간 업데이트
    adminDAO.updateLastLogin(admin.getId());

    HttpSession session = req.getSession(true);
    session.setAttribute(ADMIN_ATTR, admin);
    session.setAttribute("adminRole", admin.getRole() == null ? "admin" : admin.getRole());
    resp.sendRedirect("/AI/admin/statistics/index.jsp");
  }
}
