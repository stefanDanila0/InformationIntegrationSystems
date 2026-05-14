package org.datasource.csv.olist;

public class OrderView {
    private String order_id;
    private String customer_id;
    private String order_status;
    private String order_purchase_timestamp;
    private String order_approved_at;
    private String order_delivered_carrier_date;
    private String order_delivered_customer_date;
    private String order_estimated_delivery_date;

    public OrderView() {}

    public OrderView(String order_id, String customer_id, String order_status, String order_purchase_timestamp, String order_approved_at, String order_delivered_carrier_date, String order_delivered_customer_date, String order_estimated_delivery_date) {
        this.order_id = order_id;
        this.customer_id = customer_id;
        this.order_status = order_status;
        this.order_purchase_timestamp = order_purchase_timestamp;
        this.order_approved_at = order_approved_at;
        this.order_delivered_carrier_date = order_delivered_carrier_date;
        this.order_delivered_customer_date = order_delivered_customer_date;
        this.order_estimated_delivery_date = order_estimated_delivery_date;
    }

    // Getters and Setters
    public String getOrder_id() { return order_id; }
    public void setOrder_id(String order_id) { this.order_id = order_id; }
    public String getCustomer_id() { return customer_id; }
    public void setCustomer_id(String customer_id) { this.customer_id = customer_id; }
    public String getOrder_status() { return order_status; }
    public void setOrder_status(String order_status) { this.order_status = order_status; }
    public String getOrder_purchase_timestamp() { return order_purchase_timestamp; }
    public void setOrder_purchase_timestamp(String order_purchase_timestamp) { this.order_purchase_timestamp = order_purchase_timestamp; }
    public String getOrder_approved_at() { return order_approved_at; }
    public void setOrder_approved_at(String order_approved_at) { this.order_approved_at = order_approved_at; }
    public String getOrder_delivered_carrier_date() { return order_delivered_carrier_date; }
    public void setOrder_delivered_carrier_date(String order_delivered_carrier_date) { this.order_delivered_carrier_date = order_delivered_carrier_date; }
    public String getOrder_delivered_customer_date() { return order_delivered_customer_date; }
    public void setOrder_delivered_customer_date(String order_delivered_customer_date) { this.order_delivered_customer_date = order_delivered_customer_date; }
    public String getOrder_estimated_delivery_date() { return order_estimated_delivery_date; }
    public void setOrder_estimated_delivery_date(String order_estimated_delivery_date) { this.order_estimated_delivery_date = order_estimated_delivery_date; }
}
