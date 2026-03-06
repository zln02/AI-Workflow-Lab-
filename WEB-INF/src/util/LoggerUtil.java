package util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 로깅 유틸리티
 */
public class LoggerUtil {
    
    /**
     * Logger 인스턴스 가져오기
     * @param clazz 클래스 객체
     * @return Logger 인스턴스
     */
    public static Logger getLogger(Class<?> clazz) {
        return LoggerFactory.getLogger(clazz);
    }
    
    /**
     * 에러 로깅 (예외 포함)
     * @param logger Logger 인스턴스
     * @param message 로그 메시지
     * @param e 예외 객체
     */
    public static void logError(Logger logger, String message, Throwable e) {
        logger.error(message, e);
    }
    
    /**
     * 에러 로깅 (메시지만)
     * @param logger Logger 인스턴스
     * @param message 로그 메시지
     */
    public static void logError(Logger logger, String message) {
        logger.error(message);
    }
    
    /**
     * 정보 로깅
     * @param logger Logger 인스턴스
     * @param message 로그 메시지
     */
    public static void logInfo(Logger logger, String message) {
        logger.info(message);
    }
    
    /**
     * 디버그 로깅
     * @param logger Logger 인스턴스
     * @param message 로그 메시지
     */
    public static void logDebug(Logger logger, String message) {
        logger.debug(message);
    }
    
    /**
     * 경고 로깅
     * @param logger Logger 인스턴스
     * @param message 로그 메시지
     */
    public static void logWarn(Logger logger, String message) {
        logger.warn(message);
    }
}
