package org.datasource.mongodb.views.productcategories;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data @AllArgsConstructor @NoArgsConstructor(force = true)
public class ProductCategoryView implements Serializable {
	private String categoryName;
	private String categoryNameEnglish;
}
