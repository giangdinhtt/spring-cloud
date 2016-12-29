package com.lab.jms.client;

import org.apache.camel.CamelContext;
import org.apache.camel.Endpoint;
import org.apache.camel.Exchange;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.builder.RouteBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * Created by giang.dinh on 12/28/2016.
 */
@SpringBootApplication
@RestController
public class JmsClient {

    public static void main(String[] args) {
        SpringApplication.run(JmsClient.class, args);
    }

    @Autowired
    CamelContext camelContext;

    @Autowired
    ProducerTemplate producerTemplate;

    @RequestMapping(method = RequestMethod.GET, value = "/push")
    public String push() {
    	Endpoint endpoint = camelContext.getEndpoint("activemq:topic:test.Orders");
    	Exchange exchange = endpoint.createExchange();
    	exchange.getIn().setBody("vcl");
    	producerTemplate.asyncSend(endpoint, exchange);


        endpoint = camelContext.getEndpoint("activemq:queue:test.Ordersqueue");
        exchange = endpoint.createExchange();
        exchange.getIn().setBody("vcl");
        producerTemplate.asyncSend(endpoint, exchange);
    	return "";
    }

    @Bean
    public RouteBuilder routeBuilder() {
        RouteBuilder route = new RouteBuilder() {
            @Override
            public void configure() throws Exception {
                from("activemq:topic:test.Orders").routeId("topic-consumer").to("log:com.lab.jms.client.JmsClient?level=INFO&showAll=true");
                from("activemq:Consumer.A.test.>").routeId("virtual-topic-consumer").to("log:com.lab.jms.client.JmsClient?level=INFO&showAll=true");
            }
        };

        return route;
    }
}
