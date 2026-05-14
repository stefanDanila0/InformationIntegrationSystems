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
public class OrderCSVViewBuilder {

    private List<OrderView> viewList = new ArrayList<>();

    public List<OrderView> getViewList() {
        return viewList;
    }

    private CSVResourceFileDataSourceConnector dataSourceConnector;
    private File csvFile;

    public OrderCSVViewBuilder(CSVResourceFileDataSourceConnector dataSourceConnector) throws Exception {
        this.dataSourceConnector = dataSourceConnector;
    }

    public OrderCSVViewBuilder build() throws Exception {
        this.csvFile = dataSourceConnector.getCSVFile();
        Reader in = new FileReader(this.csvFile);
        CSVFormat format = CSVFormat.DEFAULT.withFirstRecordAsHeader().withDelimiter(',');
        Iterable<CSVRecord> records = format.parse(in);
        viewList = new ArrayList<>();
        for (CSVRecord record : records) {
            this.viewList.add(new OrderView(
                    record.get("order_id"),
                    record.get("customer_id"),
                    record.get("order_status"),
                    record.get("order_purchase_timestamp"),
                    record.get("order_approved_at"),
                    record.get("order_delivered_carrier_date"),
                    record.get("order_delivered_customer_date"),
                    record.get("order_estimated_delivery_date")
            ));
        }
        in.close();
        return this;
    }
}
