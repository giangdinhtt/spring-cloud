package com.lab.jms.client;

import org.apache.camel.builder.RouteBuilder;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

/**
 * Created by giang.dinh on 12/28/2016.
 */
@SpringBootApplication
public class JmsClient {

    public static void main(String[] args) {
        SpringApplication.run(JmsClient.class, args);
    }

    @Bean
    public RouteBuilder routeBuilder() {
        RouteBuilder route = new RouteBuilder() {
            @Override
            public void configure() throws Exception {
                from("activemq:topic:VirtualTopic.test").routeId("topic-consumer").log("log:com.lab.jms.client.JmsClient?level=DEBUG");
                from("activemq:queue:Consumer.A.VirtualTopic.test").routeId("virtual-topic-consumer").log("log:com.lab.jms.client.JmsClient?level=DEBUG");
            }
        };

        return route;
    }
}
