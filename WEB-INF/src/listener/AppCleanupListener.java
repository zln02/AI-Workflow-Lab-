package listener;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;
import db.DBConnect;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;

@WebListener
public class AppCleanupListener implements ServletContextListener {
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DBConnect.closeConnection();
        deregisterJdbcDrivers(sce);

        try {
            AbandonedConnectionCleanupThread.checkedShutdown();
            sce.getServletContext().log("MySQL abandoned connection cleanup thread stopped.");
        } catch (Exception e) {
            sce.getServletContext().log("Failed to stop MySQL cleanup thread cleanly.", e);
        }
    }

    private void deregisterJdbcDrivers(ServletContextEvent sce) {
        ClassLoader appClassLoader = Thread.currentThread().getContextClassLoader();
        Enumeration<Driver> drivers = DriverManager.getDrivers();

        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            if (driver.getClass().getClassLoader() != appClassLoader) {
                continue;
            }

            try {
                DriverManager.deregisterDriver(driver);
                sce.getServletContext().log("Deregistered JDBC driver: " + driver.getClass().getName());
            } catch (SQLException e) {
                sce.getServletContext().log("Failed to deregister JDBC driver: " + driver.getClass().getName(), e);
            }
        }
    }
}
