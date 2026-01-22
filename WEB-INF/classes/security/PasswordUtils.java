package security;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public final class PasswordUtils {
  private static final Method CHECK_METHOD = findCheckMethod();

  private PasswordUtils() {}

  public static boolean matches(String plain, String hashed) {
    if (plain == null || hashed == null || hashed.isEmpty() || CHECK_METHOD == null) {
      return false;
    }
    try {
      return (Boolean) CHECK_METHOD.invoke(null, plain, hashed);
    } catch (IllegalAccessException | InvocationTargetException e) {
      return false;
    }
  }

  private static Method findCheckMethod() {
    try {
      Class<?> bcrypt = Class.forName("org.mindrot.jbcrypt.BCrypt");
      return bcrypt.getMethod("checkpw", String.class, String.class);
    } catch (ClassNotFoundException | NoSuchMethodException e) {
      return null;
    }
  }
}
