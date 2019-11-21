package com.pivotal.task.taskdemo;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.task.configuration.EnableTask;
import org.springframework.context.annotation.Bean;
import org.springframework.util.StopWatch;

import java.time.Instant;

@SpringBootApplication
@EnableTask
@Slf4j
public class TaskDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(TaskDemoApplication.class, args);
    }

    @Bean
    ApplicationRunner run() {
        return args -> {
            log.info("Start {}", Instant.now());

            StopWatch taskWatch = new StopWatch("`Task`");
            taskWatch.start();

            args.getOptionNames().forEach(a -> log.info("arg: {} {}", a, args.getOptionValues(a)));

            long sleepTime = Long.valueOf(args.getOptionValues("sleep").get(0));
            long waitTime = Long.valueOf(args.getOptionValues("wait").get(0));

            Thread.sleep(sleepTime);
            taskWatch.stop();

            long totalSeconds = taskWatch.getTotalTimeMillis();

            log.info("Sleep: {}, Wait: {}, TotalMilliSeconds: {}", sleepTime, waitTime, totalSeconds);

            if(totalSeconds > waitTime) {
            	throw new RuntimeException("Error application took too long!");
			}

            log.info("Completed Successfully!");
        };
    }
}
