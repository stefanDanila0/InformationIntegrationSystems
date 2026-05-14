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
@Table(name = "OLAP_VIEW_SALES_RANK")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class OLAP_VIEW_SALES_RANK implements Serializable {
    @Id
    @Column(name = "customerState")
    private String customerState;

    @Column(name = "totalSalesAmount")
    private Double totalSalesAmount;

    @Column(name = "orderCount")
    private Long orderCount;

    @Column(name = "salesRank")
    private Integer salesRank;

    @Column(name = "salesDenseRank")
    private Integer salesDenseRank;

    @Column(name = "salesPercentRank")
    private Double salesPercentRank;

    @Column(name = "salesRowNumber")
    private Integer salesRowNumber;
}
