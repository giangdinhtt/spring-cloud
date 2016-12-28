package com.lab.config.service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.config.server.EnableConfigServer;

/**
 * Created by giang.dinh on 12/23/2016.
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableConfigServer
public class ConfigService {

    public static void main(String[] args) {
        SpringApplication.run(ConfigService.class, args);
    }
}
