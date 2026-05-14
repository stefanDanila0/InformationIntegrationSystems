package org.datasource.csv.olist;

public class OrderItemView {
    private String order_id;
    private Integer order_item_id;
    private String product_id;
    private String seller_id;
    private String shipping_limit_date;
    private Double price;
    private Double freight_value;

    public OrderItemView() {}

    public OrderItemView(String order_id, Integer order_item_id, String product_id, String seller_id, String shipping_limit_date, Double price, Double freight_value) {
        this.order_id = order_id;
        this.order_item_id = order_item_id;
        this.product_id = product_id;
        this.seller_id = seller_id;
        this.shipping_limit_date = shipping_limit_date;
        this.price = price;
        this.freight_value = freight_value;
    }

    // Getters and Setters
    public String getOrder_id() { return order_id; }
    public void setOrder_id(String order_id) { this.order_id = order_id; }
    public Integer getOrder_item_id() { return order_item_id; }
    public void setOrder_item_id(Integer order_item_id) { this.order_item_id = order_item_id; }
    public String getProduct_id() { return product_id; }
    public void setProduct_id(String product_id) { this.product_id = product_id; }
    public String getSeller_id() { return seller_id; }
    public void setSeller_id(String seller_id) { this.seller_id = seller_id; }
    public String getShipping_limit_date() { return shipping_limit_date; }
    public void setShipping_limit_date(String shipping_limit_date) { this.shipping_limit_date = shipping_limit_date; }
    public Double getPrice() { return price; }
    public void setPrice(Double price) { this.price = price; }
    public Double getFreight_value() { return freight_value; }
    public void setFreight_value(Double freight_value) { this.freight_value = freight_value; }
}
