package com.interviewportal.model;

import java.sql.Date;
import java.sql.Timestamp;

public class InterviewExperience {
    private int id;
    private int userId;
    private String companyName;
    private String role;
    private Date interviewDate;
    private int roundsCount;
    private String questionsAsked;
    private String difficultyLevel;
    private String result;
    private String tips;
    private Timestamp createdAt;
    
    // Auxiliary field for UI display (joining with users table)
    private String username;

    public InterviewExperience() {}

    public InterviewExperience(int id, int userId, String companyName, String role, Date interviewDate, 
                               int roundsCount, String questionsAsked, String difficultyLevel, 
                               String result, String tips, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.companyName = companyName;
        this.role = role;
        this.interviewDate = interviewDate;
        this.roundsCount = roundsCount;
        this.questionsAsked = questionsAsked;
        this.difficultyLevel = difficultyLevel;
        this.result = result;
        this.tips = tips;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Date getInterviewDate() {
        return interviewDate;
    }

    public void setInterviewDate(Date interviewDate) {
        this.interviewDate = interviewDate;
    }

    public int getRoundsCount() {
        return roundsCount;
    }

    public void setRoundsCount(int roundsCount) {
        this.roundsCount = roundsCount;
    }

    public String getQuestionsAsked() {
        return questionsAsked;
    }

    public void setQuestionsAsked(String questionsAsked) {
        this.questionsAsked = questionsAsked;
    }

    public String getDifficultyLevel() {
        return difficultyLevel;
    }

    public void setDifficultyLevel(String difficultyLevel) {
        this.difficultyLevel = difficultyLevel;
    }

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getTips() {
        return tips;
    }

    public void setTips(String tips) {
        this.tips = tips;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    @Override
    public String toString() {
        return "InterviewExperience{" +
                "id=" + id +
                ", userId=" + userId +
                ", companyName='" + companyName + '\'' +
                ", role='" + role + '\'' +
                ", result='" + result + '\'' +
                '}';
    }
}
