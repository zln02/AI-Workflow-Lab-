package model;

import java.math.BigDecimal;

public class CreditPackage {
    private int id;
    private String packageName;
    private int credits;
    private BigDecimal price;
    private int bonusCredits;
    private boolean active;
    private int displayOrder;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }

    public int getCredits() {
        return credits;
    }

    public void setCredits(int credits) {
        this.credits = credits;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public int getBonusCredits() {
        return bonusCredits;
    }

    public void setBonusCredits(int bonusCredits) {
        this.bonusCredits = bonusCredits;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }
}
