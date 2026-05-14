package org.datasource.csv.custcategories;

public class CustomerCategoryView {
	private String categoryCode;
	private String categoryName;
	private Double lowerBound;
	private Double upperBound;

	public CustomerCategoryView() {}

	public CustomerCategoryView(String categoryCode, String categoryName, Double lowerBound, Double upperBound) {
		this.categoryCode = categoryCode;
		this.categoryName = categoryName;
		this.lowerBound = lowerBound;
		this.upperBound = upperBound;
	}

	public String getCategoryCode() { return categoryCode; }
	public void setCategoryCode(String categoryCode) { this.categoryCode = categoryCode; }
	public String getCategoryName() { return categoryName; }
	public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
	public Double getLowerBound() { return lowerBound; }
	public void setLowerBound(Double lowerBound) { this.lowerBound = lowerBound; }
	public Double getUpperBound() { return upperBound; }
	public void setUpperBound(Double upperBound) { this.upperBound = upperBound; }
}
