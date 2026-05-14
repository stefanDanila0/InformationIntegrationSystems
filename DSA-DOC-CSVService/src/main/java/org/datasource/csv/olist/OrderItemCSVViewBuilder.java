package org.datasource.csv.olist;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.datasource.csv.CSVResourceFileDataSourceConnector;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.FileReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;

@Service
public class OrderItemCSVViewBuilder {

    private List<OrderItemView> viewList = new ArrayList<>();

    public List<OrderItemView> getViewList() {
        return viewList;
    }

    private CSVResourceFileDataSourceConnector dataSourceConnector;

    public OrderItemCSVViewBuilder(CSVResourceFileDataSourceConnector dataSourceConnector) throws Exception {
        this.dataSourceConnector = dataSourceConnector;
    }

    public OrderItemCSVViewBuilder build() throws Exception {
        File ordersFile = dataSourceConnector.getCSVFile();
        // Assume items file is in the same directory
        File itemsFile = new File(ordersFile.getParent(), "olist_order_items_dataset.csv");
        
        Reader in = new FileReader(itemsFile);
        CSVFormat format = CSVFormat.DEFAULT.withFirstRecordAsHeader().withDelimiter(',');
        Iterable<CSVRecord> records = format.parse(in);
        viewList = new ArrayList<>();
        for (CSVRecord record : records) {
            this.viewList.add(new OrderItemView(
                    record.get("order_id"),
                    Integer.parseInt(record.get("order_item_id")),
                    record.get("product_id"),
                    record.get("seller_id"),
                    record.get("shipping_limit_date"),
                    Double.parseDouble(record.get("price")),
                    Double.parseDouble(record.get("freight_value"))
            ));
        }
        in.close();
        return this;
    }
}
