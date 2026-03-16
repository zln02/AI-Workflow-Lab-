package util;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

public class EncryptionUtil {
    private static final String PREFIX = "enc:";
    private static final int IV_LENGTH = 12;
    private static final int TAG_LENGTH = 128;
    private static final String LEGACY_DEFAULT_KEY = "codex-default-encryption-key-32b";
    private static final String ENCRYPTION_KEY_ENV = "ENCRYPTION_KEY";

    private EncryptionUtil() {}

    public static String encrypt(String plainText) {
        if (plainText == null || plainText.isEmpty()) {
            return plainText;
        }
        try {
            SecretKey key = resolveKey();
            byte[] iv = new byte[IV_LENGTH];
            new SecureRandom().nextBytes(iv);

            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.ENCRYPT_MODE, key, new GCMParameterSpec(TAG_LENGTH, iv));
            byte[] encrypted = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));

            ByteBuffer buffer = ByteBuffer.allocate(iv.length + encrypted.length);
            buffer.put(iv);
            buffer.put(encrypted);
            return PREFIX + Base64.getEncoder().encodeToString(buffer.array());
        } catch (Exception e) {
            return null;
        }
    }

    public static String decrypt(String value) {
        if (value == null || value.isEmpty() || !value.startsWith(PREFIX)) {
            return value;
        }
        try {
            byte[] payload = Base64.getDecoder().decode(value.substring(PREFIX.length()));
            Exception lastError = null;
            for (SecretKey key : resolveDecryptionKeys()) {
                try {
                    return decryptPayload(payload, key);
                } catch (Exception e) {
                    lastError = e;
                }
            }
            if (lastError != null) {
                throw lastError;
            }
            return value;
        } catch (Exception e) {
            return value;
        }
    }

    public static String mask(String value) {
        if (value == null || value.isEmpty()) {
            return "";
        }
        String plain = decrypt(value);
        if (plain.length() <= 8) {
            return "****";
        }
        return plain.substring(0, 4) + "..." + plain.substring(plain.length() - 4);
    }

    public static String tryDecryptWithCurrentKey(String value) {
        try {
            return decryptWithKey(value, resolveKey());
        } catch (Exception e) {
            return null;
        }
    }

    public static String tryDecryptWithLegacyKey(String value) {
        try {
            return decryptWithKey(value, secretKeyFromString(LEGACY_DEFAULT_KEY));
        } catch (Exception e) {
            return null;
        }
    }

    private static SecretKey resolveKey() throws Exception {
        String envKey = System.getenv(ENCRYPTION_KEY_ENV);
        if (envKey == null || envKey.trim().isEmpty()) {
            throw new IllegalStateException("ENCRYPTION_KEY is not configured");
        }
        return secretKeyFromString(envKey);
    }

    private static SecretKey[] resolveDecryptionKeys() throws Exception {
        String envKey = System.getenv(ENCRYPTION_KEY_ENV);
        if (envKey == null || envKey.trim().isEmpty() || LEGACY_DEFAULT_KEY.equals(envKey)) {
            return new SecretKey[]{secretKeyFromString(LEGACY_DEFAULT_KEY)};
        }
        return new SecretKey[]{
                secretKeyFromString(envKey),
                secretKeyFromString(LEGACY_DEFAULT_KEY)
        };
    }

    private static SecretKey secretKeyFromString(String keyValue) {
        byte[] raw = keyValue.getBytes(StandardCharsets.UTF_8);
        byte[] keyBytes = new byte[32];
        for (int i = 0; i < keyBytes.length; i++) {
            keyBytes[i] = i < raw.length ? raw[i] : (byte) 0;
        }
        return new SecretKeySpec(keyBytes, "AES");
    }

    private static String decryptPayload(byte[] payload, SecretKey key) throws Exception {
        ByteBuffer buffer = ByteBuffer.wrap(payload);
        byte[] iv = new byte[IV_LENGTH];
        buffer.get(iv);
        byte[] encrypted = new byte[buffer.remaining()];
        buffer.get(encrypted);

        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.DECRYPT_MODE, key, new GCMParameterSpec(TAG_LENGTH, iv));
        return new String(cipher.doFinal(encrypted), StandardCharsets.UTF_8);
    }

    private static String decryptWithKey(String value, SecretKey key) throws Exception {
        if (value == null || value.isEmpty() || !value.startsWith(PREFIX)) {
            return value;
        }
        byte[] payload = Base64.getDecoder().decode(value.substring(PREFIX.length()));
        return decryptPayload(payload, key);
    }
}
