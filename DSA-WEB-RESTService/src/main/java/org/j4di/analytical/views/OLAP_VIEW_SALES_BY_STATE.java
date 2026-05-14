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
@Table(name = "OLAP_VIEW_SALES_BY_STATE")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class OLAP_VIEW_SALES_BY_STATE implements Serializable {
    @Id
    @Column(name = "customerState")
    private String customerState;

    @Column(name = "orderCount")
    private Long orderCount;

    @Column(name = "totalSalesAmount")
    private Double totalSalesAmount;

    @Column(name = "avgOrderAmount")
    private Double avgOrderAmount;
}
