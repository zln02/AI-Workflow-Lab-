package util;

/**
 * XSS 방지를 위한 HTML escape 유틸리티
 */
public class EscapeUtil {
    
    /**
     * HTML 태그를 escape 처리
     * @param input escape 처리할 문자열
     * @return escape 처리된 문자열
     */
    public static String escapeHtml(String input) {
        if (input == null) {
            return "";
        }
        
        StringBuilder escaped = new StringBuilder();
        for (char c : input.toCharArray()) {
            switch (c) {
                case '<':
                    escaped.append("&lt;");
                    break;
                case '>':
                    escaped.append("&gt;");
                    break;
                case '&':
                    escaped.append("&amp;");
                    break;
                case '"':
                    escaped.append("&quot;");
                    break;
                case '\'':
                    escaped.append("&#x27;");
                    break;
                case '/':
                    escaped.append("&#x2F;");
                    break;
                default:
                    escaped.append(c);
                    break;
            }
        }
        return escaped.toString();
    }
    
    /**
     * JavaScript 문자열을 escape 처리
     * @param input escape 처리할 문자열
     * @return escape 처리된 문자열
     */
    public static String escapeJavaScript(String input) {
        if (input == null) {
            return "";
        }
        
        StringBuilder escaped = new StringBuilder();
        for (char c : input.toCharArray()) {
            switch (c) {
                case '"':
                    escaped.append("\\\"");
                    break;
                case '\'':
                    escaped.append("\\'");
                    break;
                case '\\':
                    escaped.append("\\\\");
                    break;
                case '\n':
                    escaped.append("\\n");
                    break;
                case '\r':
                    escaped.append("\\r");
                    break;
                case '\t':
                    escaped.append("\\t");
                    break;
                default:
                    if (c < 32 || c > 126) {
                        escaped.append(String.format("\\u%04x", (int) c));
                    } else {
                        escaped.append(c);
                    }
                    break;
            }
        }
        return escaped.toString();
    }
    
    /**
     * SQL LIKE 패턴을 escape 처리
     * @param input escape 처리할 문자열
     * @return escape 처리된 문자열
     */
    public static String escapeSqlLike(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\")
                   .replace("%", "\\%")
                   .replace("_", "\\_");
    }
}
