package org.datasource.springdata.views;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Entity
@Table(name = "sellers")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class SellerView implements Serializable {
    @Id
    @Column(name = "seller_id")
    private String sellerId;

    @Column(name = "seller_zip_code_prefix")
    private Integer sellerZipCodePrefix;

    @Column(name = "seller_city")
    private String sellerCity;

    @Column(name = "seller_state")
    private String sellerState;
}
