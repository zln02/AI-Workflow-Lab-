package dao;

import java.sql.*;
import java.util.*;
import model.Package;
import db.DBConnect;

public class PackageDAO {
    private Connection conn;
    
    public PackageDAO() {
        this.conn = DBConnect.getConnection();
    }
    
    // 추천 패키지 가져오기
    public List<Package> getFeaturedPackages(int limit) {
        List<Package> packages = new ArrayList<>();
        String sql = "SELECT * FROM packages WHERE is_active = 1 AND is_featured = 1 ORDER BY display_order ASC, created_at DESC LIMIT ?";
        
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Package pkg = new Package();
                pkg.setId(rs.getInt("id"));
                pkg.setTitle(rs.getString("title"));
                pkg.setDescription(rs.getString("description"));
                pkg.setPrice(rs.getBigDecimal("price"));
                pkg.setDiscountPrice(rs.getBigDecimal("discount_price"));
                pkg.setIsActive(rs.getBoolean("is_active"));
                pkg.setIsFeatured(rs.getBoolean("is_featured"));
                pkg.setDisplayOrder(rs.getInt("display_order"));
                pkg.setCreatedAt(rs.getTimestamp("created_at"));
                pkg.setUpdatedAt(rs.getTimestamp("updated_at"));
                packages.add(pkg);
            }
            
            rs.close();
            pstmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return packages;
    }
    
    // 모든 패키지 가져오기 (페이징)
    public List<Package> getAllPackages(int page, int pageSize) {
        List<Package> packages = new ArrayList<>();
        String sql = "SELECT * FROM packages WHERE is_active = 1 ORDER BY display_order ASC, created_at DESC LIMIT ? OFFSET ?";
        
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, pageSize);
            pstmt.setInt(2, (page - 1) * pageSize);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Package pkg = new Package();
                pkg.setId(rs.getInt("id"));
                pkg.setTitle(rs.getString("title"));
                pkg.setDescription(rs.getString("description"));
                pkg.setPrice(rs.getBigDecimal("price"));
                pkg.setDiscountPrice(rs.getBigDecimal("discount_price"));
                pkg.setIsActive(rs.getBoolean("is_active"));
                pkg.setIsFeatured(rs.getBoolean("is_featured"));
                pkg.setDisplayOrder(rs.getInt("display_order"));
                pkg.setCreatedAt(rs.getTimestamp("created_at"));
                pkg.setUpdatedAt(rs.getTimestamp("updated_at"));
                packages.add(pkg);
            }
            
            rs.close();
            pstmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return packages;
    }
    
    // 패키지 상세 정보 가져오기
    public Package getPackageById(int id) {
        String sql = "SELECT * FROM packages WHERE id = ? AND is_active = 1";
        
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Package pkg = new Package();
                pkg.setId(rs.getInt("id"));
                pkg.setTitle(rs.getString("title"));
                pkg.setDescription(rs.getString("description"));
                pkg.setPrice(rs.getBigDecimal("price"));
                pkg.setDiscountPrice(rs.getBigDecimal("discount_price"));
                pkg.setIsActive(rs.getBoolean("is_active"));
                pkg.setIsFeatured(rs.getBoolean("is_featured"));
                pkg.setDisplayOrder(rs.getInt("display_order"));
                pkg.setCreatedAt(rs.getTimestamp("created_at"));
                pkg.setUpdatedAt(rs.getTimestamp("updated_at"));
                
                rs.close();
                pstmt.close();
                return pkg;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    // 패키지에 포함된 모델 목록 가져오기
    public List<Integer> getPackageModels(int packageId) {
        List<Integer> modelIds = new ArrayList<>();
        String sql = "SELECT model_id FROM package_items WHERE package_id = ?";
        
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, packageId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                modelIds.add(rs.getInt("model_id"));
            }
            
            rs.close();
            pstmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return modelIds;
    }
    
    // 전체 패키지 수 가져오기
    public int getTotalPackageCount() {
        String sql = "SELECT COUNT(*) FROM packages WHERE is_active = 1";
        
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    // 패키지 추가
    public boolean addPackage(Package pkg) {
        String sql = "INSERT INTO packages (title, description, price, discount_price, is_active, is_featured, display_order) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, pkg.getTitle());
            pstmt.setString(2, pkg.getDescription());
            pstmt.setBigDecimal(3, pkg.getPrice());
            pstmt.setBigDecimal(4, pkg.getDiscountPrice());
            pstmt.setBoolean(5, pkg.getIsActive());
            pstmt.setBoolean(6, pkg.getIsFeatured());
            pstmt.setInt(7, pkg.getDisplayOrder());
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                ResultSet generatedKeys = pstmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    pkg.setId(generatedKeys.getInt(1));
                }
                generatedKeys.close();
            }
            
            pstmt.close();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 패키지 수정
    public boolean updatePackage(Package pkg) {
        String sql = "UPDATE packages SET title = ?, description = ?, price = ?, discount_price = ?, " +
                    "is_active = ?, is_featured = ?, display_order = ?, updated_at = NOW() WHERE id = ?";
        
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, pkg.getTitle());
            pstmt.setString(2, pkg.getDescription());
            pstmt.setBigDecimal(3, pkg.getPrice());
            pstmt.setBigDecimal(4, pkg.getDiscountPrice());
            pstmt.setBoolean(5, pkg.getIsActive());
            pstmt.setBoolean(6, pkg.getIsFeatured());
            pstmt.setInt(7, pkg.getDisplayOrder());
            pstmt.setInt(8, pkg.getId());
            
            int result = pstmt.executeUpdate();
            pstmt.close();
            
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 패키지에 모델 추가
    public boolean addModelToPackage(int packageId, int modelId) {
        String sql = "INSERT INTO package_items (package_id, model_id) VALUES (?, ?)";
        
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, packageId);
            pstmt.setInt(2, modelId);
            
            int result = pstmt.executeUpdate();
            pstmt.close();
            
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 패키지에서 모델 제거
    public boolean removeModelFromPackage(int packageId, int modelId) {
        String sql = "DELETE FROM package_items WHERE package_id = ? AND model_id = ?";
        
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, packageId);
            pstmt.setInt(2, modelId);
            
            int result = pstmt.executeUpdate();
            pstmt.close();
            
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // 패키지 삭제 (비활성화)
    public boolean deletePackage(int id) {
        String sql = "UPDATE packages SET is_active = 0, updated_at = NOW() WHERE id = ?";
        
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            
            int result = pstmt.executeUpdate();
            pstmt.close();
            
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
}
