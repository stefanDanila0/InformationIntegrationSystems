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
@Table(name = "customers")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class CustomerView implements Serializable {
    @Id
    @Column(name = "customer_id")
    private String customerId;

    @Column(name = "customer_unique_id")
    private String customerUniqueId;

    @Column(name = "customer_zip_code_prefix")
    private Integer customerZipCodePrefix;

    @Column(name = "customer_city")
    private String customerCity;

    @Column(name = "customer_state")
    private String customerState;
}
