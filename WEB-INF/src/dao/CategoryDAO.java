package dao;

import model.Category;
import util.DBConnect;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {
    private java.sql.Connection conn;
    
    public CategoryDAO() {
        this.conn = DBConnect.getConnection();
    }
    
    // 활성화된 모든 카테고리 가져오기
    public List<Category> getAllActiveCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT * FROM categories WHERE is_active = 1 ORDER BY display_order ASC, category_name ASC";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            try (java.sql.ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Category category = new Category();
                    category.setId(rs.getInt("id"));
                    category.setCategoryName(rs.getString("category_name"));
                    category.setDescription(rs.getString("description"));
                    category.setIcon(rs.getString("icon"));
                    category.setDisplayOrder(rs.getInt("display_order"));
                    category.setIsActive(rs.getBoolean("is_active"));
                    category.setCreatedAt(rs.getTimestamp("created_at"));
                    category.setUpdatedAt(rs.getTimestamp("updated_at"));
                    categories.add(category);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return categories;
    }
    
    // 모든 카테고리 가져오기
    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT * FROM categories ORDER BY display_order ASC, category_name ASC";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            try (java.sql.ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Category category = new Category();
                    category.setId(rs.getInt("id"));
                    category.setCategoryName(rs.getString("category_name"));
                    category.setDescription(rs.getString("description"));
                    category.setIcon(rs.getString("icon"));
                    category.setDisplayOrder(rs.getInt("display_order"));
                    category.setIsActive(rs.getBoolean("is_active"));
                    category.setCreatedAt(rs.getTimestamp("created_at"));
                    category.setUpdatedAt(rs.getTimestamp("updated_at"));
                    categories.add(category);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return categories;
    }
    
    // ID로 카테고리 가져오기
    public Category getCategoryById(int id) {
        String sql = "SELECT * FROM categories WHERE id = ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Category category = new Category();
                    category.setId(rs.getInt("id"));
                    category.setCategoryName(rs.getString("category_name"));
                    category.setDescription(rs.getString("description"));
                    category.setIcon(rs.getString("icon"));
                    category.setDisplayOrder(rs.getInt("display_order"));
                    category.setIsActive(rs.getBoolean("is_active"));
                    category.setCreatedAt(rs.getTimestamp("created_at"));
                    category.setUpdatedAt(rs.getTimestamp("updated_at"));
                    
                    return category;
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    // 카테고리 추가
    public boolean addCategory(Category category) {
        String sql = "INSERT INTO categories (category_name, description, icon, display_order, is_active) VALUES (?, ?, ?, ?, ?)";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, category.getCategoryName());
            pstmt.setString(2, category.getDescription());
            pstmt.setString(3, category.getIcon());
            pstmt.setInt(4, category.getDisplayOrder());
            pstmt.setBoolean(5, category.getIsActive());
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                try (java.sql.ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        category.setId(generatedKeys.getInt(1));
                    }
                }
            }
            
            return result > 0;
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 카테고리 수정
    public boolean updateCategory(Category category) {
        String sql = "UPDATE categories SET category_name = ?, description = ?, icon = ?, " +
                    "display_order = ?, is_active = ?, updated_at = NOW() WHERE id = ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, category.getCategoryName());
            pstmt.setString(2, category.getDescription());
            pstmt.setString(3, category.getIcon());
            pstmt.setInt(4, category.getDisplayOrder());
            pstmt.setBoolean(5, category.getIsActive());
            pstmt.setInt(6, category.getId());
            
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 카테고리 삭제 (비활성화)
    public boolean deleteCategory(int id) {
        String sql = "UPDATE categories SET is_active = 0 WHERE id = ?";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 최대 display_order 값 가져오기
    public int getMaxDisplayOrder() {
        String sql = "SELECT MAX(display_order) FROM categories";
        
        try (java.sql.Connection conn = DBConnect.getConnection();
             java.sql.PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            try (java.sql.ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
}
