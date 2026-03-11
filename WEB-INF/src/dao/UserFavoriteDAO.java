package dao;

import model.UserFavorite;
import db.DBConnect;
import java.util.ArrayList;
import java.util.List;

/**
 * 사용자 즐겨찾기 DAO
 */
public class UserFavoriteDAO {
    
    /**
     * 즐겨찾기 추가
     */
    public boolean addFavorite(UserFavorite favorite) {
        String sql = "INSERT INTO user_favorites (user_id, item_id, category, created_at) VALUES (?, ?, ?, ?)";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, favorite.getUserId());
            pstmt.setInt(2, favorite.getToolId());
            pstmt.setString(3, favorite.getCategory());
            pstmt.setTimestamp(4, favorite.getCreatedAt());
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                try (java.sql.ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        favorite.setId(generatedKeys.getInt(1));
                    }
                }
            }
            
            return result > 0;
            
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * 즐겨찾기 삭제
     */
    public boolean removeFavorite(int userId, int itemId, String category) {
        String sql = "DELETE FROM user_favorites WHERE user_id = ? AND item_id = ? AND category = ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, itemId);
            pstmt.setString(3, category);
            
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * 사용자의 모든 즐겨찾기 가져오기
     */
    public List<UserFavorite> getUserFavorites(int userId) {
        List<UserFavorite> favorites = new ArrayList<>();
        String sql = "SELECT * FROM user_favorites WHERE user_id = ? ORDER BY created_at DESC";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    UserFavorite favorite = new UserFavorite();
                    favorite.setId(rs.getInt("id"));
                    favorite.setUserId(rs.getInt("user_id"));
                    favorite.setToolId(rs.getInt("item_id"));
                    favorite.setCategory(rs.getString("category"));
                    favorite.setCreatedAt(rs.getTimestamp("created_at"));
                    favorites.add(favorite);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return favorites;
    }
    
    /**
     * 특정 카테고리의 즐겨찾기 가져오기
     */
    public List<UserFavorite> getUserFavoritesByCategory(int userId, String category) {
        List<UserFavorite> favorites = new ArrayList<>();
        String sql = "SELECT * FROM user_favorites WHERE user_id = ? AND category = ? ORDER BY created_at DESC";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setString(2, category);
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    UserFavorite favorite = new UserFavorite();
                    favorite.setId(rs.getInt("id"));
                    favorite.setUserId(rs.getInt("user_id"));
                    favorite.setToolId(rs.getInt("item_id"));
                    favorite.setCategory(rs.getString("category"));
                    favorite.setCreatedAt(rs.getTimestamp("created_at"));
                    favorites.add(favorite);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return favorites;
    }
    
    /**
     * 즐겨찾기 여부 확인
     */
    public boolean isFavorite(int userId, int itemId, String category) {
        String sql = "SELECT COUNT(*) FROM user_favorites WHERE user_id = ? AND item_id = ? AND category = ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, itemId);
            pstmt.setString(3, category);
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * 즐겨찾기 토글 (있으면 삭제, 없으면 추가)
     */
    public boolean toggleFavorite(int userId, int itemId, String category) {
        if (isFavorite(userId, itemId, category)) {
            return removeFavorite(userId, itemId, category);
        } else {
            UserFavorite favorite = new UserFavorite(userId, itemId, category);
            return addFavorite(favorite);
        }
    }
    
    /**
     * 아이템의 즐겨찾기 수 가져오기
     */
    public int getFavoriteCount(int itemId, String category) {
        String sql = "SELECT COUNT(*) FROM user_favorites WHERE item_id = ? AND category = ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, itemId);
            pstmt.setString(2, category);
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * 인기 아이템 가져오기 (즐겨찾기 수 기준)
     */
    public List<Integer> getPopularItems(String category, int limit) {
        List<Integer> itemIds = new ArrayList<>();
        String sql = "SELECT item_id, COUNT(*) as favorite_count FROM user_favorites " +
                    "WHERE category = ? GROUP BY item_id ORDER BY favorite_count DESC LIMIT ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, category);
            pstmt.setInt(2, limit);
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    itemIds.add(rs.getInt("item_id"));
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return itemIds;
    }
}
