package model;

public class PackageItem {
  private int id;
  private int packageId;
  private int modelId;
  private int quantity;
  private String createdAt;
  private AIModel model; // 조인된 AI 모델 정보

  public PackageItem() {}

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

  public int getPackageId() {
    return packageId;
  }

  public void setPackageId(int packageId) {
    this.packageId = packageId;
  }

  public int getModelId() {
    return modelId;
  }

  public void setModelId(int modelId) {
    this.modelId = modelId;
  }

  public int getQuantity() {
    return quantity;
  }

  public void setQuantity(int quantity) {
    this.quantity = quantity;
  }

  public String getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(String createdAt) {
    this.createdAt = createdAt;
  }

  public AIModel getModel() {
    return model;
  }

  public void setModel(AIModel model) {
    this.model = model;
  }
}

