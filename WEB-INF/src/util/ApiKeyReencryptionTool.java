package util;

import db.DBConnect;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ApiKeyReencryptionTool {
    public static void main(String[] args) throws Exception {
        int scanned = 0;
        int migrated = 0;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement select = conn.prepareStatement(
                     "SELECT id, api_key_enc FROM user_api_keys ORDER BY id");
             ResultSet rs = select.executeQuery()) {

            while (rs.next()) {
                scanned++;
                int id = rs.getInt("id");
                String encrypted = rs.getString("api_key_enc");

                String currentPlain = EncryptionUtil.tryDecryptWithCurrentKey(encrypted);
                String legacyPlain = EncryptionUtil.tryDecryptWithLegacyKey(encrypted);

                if (legacyPlain == null) {
                    continue;
                }
                if (currentPlain != null && currentPlain.equals(legacyPlain)) {
                    continue;
                }

                String reencrypted = EncryptionUtil.encrypt(legacyPlain);
                try (PreparedStatement update = conn.prepareStatement(
                        "UPDATE user_api_keys SET api_key_enc = ?, updated_at = NOW() WHERE id = ?")) {
                    update.setString(1, reencrypted);
                    update.setInt(2, id);
                    migrated += update.executeUpdate();
                }
            }
        }

        System.out.println("scanned=" + scanned);
        System.out.println("migrated=" + migrated);
    }
}
