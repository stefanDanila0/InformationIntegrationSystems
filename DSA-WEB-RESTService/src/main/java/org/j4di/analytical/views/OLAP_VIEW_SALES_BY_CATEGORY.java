package org.j4di.analytical.views;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Entity
@Table(name = "OLAP_VIEW_SALES_BY_CATEGORY")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class OLAP_VIEW_SALES_BY_CATEGORY implements Serializable {
    @Id
    @Column(name = "categoryName")
    private String categoryName;

    @Column(name = "sellerState")
    private String sellerState;

    @Column(name = "orderCount")
    private Long orderCount;

    @Column(name = "totalSalesAmount")
    private Double totalSalesAmount;
}
