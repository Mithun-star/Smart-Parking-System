package com.interviewportal.model;

import java.sql.Timestamp;

public class AnalyticsLog {
    private int id;
    private String eventType;
    private String description;
    private Timestamp createdAt;

    public AnalyticsLog() {}

    public AnalyticsLog(int id, String eventType, String description, Timestamp createdAt) {
        this.id = id;
        this.eventType = eventType;
        this.description = description;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "AnalyticsLog{" +
                "id=" + id +
                ", eventType='" + eventType + '\'' +
                ", description='" + description + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
