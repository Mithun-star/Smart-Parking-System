package com.interviewportal.service;

import com.interviewportal.dao.AnalyticsDAO;
import com.interviewportal.model.AnalyticsLog;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class AnalyticsService {
    private final AnalyticsDAO analyticsDAO = new AnalyticsDAO();

    public void logEvent(String eventType, String description) {
        analyticsDAO.logEvent(eventType, description);
    }

    public int getTotalExperiences() {
        return analyticsDAO.getTotalExperiencesCount();
    }

    public List<AnalyticsLog> getAllLogs() {
        return analyticsDAO.getAllLogs();
    }

    /**
     * Aggregates and returns company-wise count sorted alphabetically.
     * Demonstrates HashMap to TreeMap conversion (Module 1).
     */
    public Map<String, Integer> getCompanyExperienceCountsSorted() {
        Map<String, Integer> rawMap = analyticsDAO.getCompanyExperienceCountsRaw();
        // Convert to TreeMap to automatically sort alphabetically by company name
        Map<String, Integer> sortedMap = new TreeMap<>(rawMap);
        return sortedMap;
    }

    /**
     * Computes the selection rate percentage.
     * Demonstrates equalsIgnoreCase() and String.valueOf() (Module 2).
     */
    public double getSelectionRate() {
        Map<String, Integer> resultCounts = analyticsDAO.getResultCountsRaw();
        int total = 0;
        int selected = 0;

        Iterator<Map.Entry<String, Integer>> iterator = resultCounts.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, Integer> entry = iterator.next();
            String key = entry.getKey();
            int val = entry.getValue();
            total += val;
            
            // Check matching (equalsIgnoreCase)
            if ("Selected".equalsIgnoreCase(key.trim())) {
                selected = val;
            }
        }

        if (total == 0) return 0.0;
        double rate = ((double) selected / total) * 100;
        
        // Return rounded rate
        return Math.round(rate * 100.0) / 100.0;
    }

    /**
     * Finds the companies with the most experiences.
     * Demonstrates sorting map entries (Module 1).
     */
    public List<Map.Entry<String, Integer>> getMostFrequentCompanies(int limit) {
        Map<String, Integer> rawMap = analyticsDAO.getCompanyExperienceCountsRaw();
        List<Map.Entry<String, Integer>> entryList = new ArrayList<>(rawMap.entrySet());

        // Sort entries by value descending
        Collections.sort(entryList, new Comparator<Map.Entry<String, Integer>>() {
            @Override
            public int compare(Map.Entry<String, Integer> o1, Map.Entry<String, Integer> o2) {
                return o2.getValue().compareTo(o1.getValue());
            }
        });

        if (entryList.size() > limit) {
            return entryList.subList(0, limit);
        }
        return entryList;
    }

    /**
     * Analyzes all interview questions to find the most frequently asked topics.
     * Uses String contains() and toLowerCase() to map keywords to counts (Module 2).
     * Accumulates a thread-safe report using StringBuffer (Module 2).
     */
    public Map<String, Integer> getMostFrequentTopics() {
        List<String> questionsList = analyticsDAO.getAllQuestions();
        Map<String, Integer> topicCounts = new HashMap<>();

        // List of common software interview topics to scan for
        String[] topicsToScan = {
            "Binary Tree", "Dynamic Programming", "LRU Cache", "System Design",
            "Linked List", "Graphs", "SQL", "DBMS", "Recursion", "Sorting",
            "Singleton", "Factory Pattern", "Behavioral", "Design Patterns",
            "String Manipulation", "Array"
        };

        // Initialize map
        for (String topic : topicsToScan) {
            topicCounts.put(topic, 0);
        }

        // Iterate questions using Iterator (Module 1)
        Iterator<String> iterator = questionsList.iterator();
        while (iterator.hasNext()) {
            String question = iterator.next();
            if (question == null) continue;

            String cleanQuestion = question.toLowerCase();
            for (String topic : topicsToScan) {
                // Perform case-insensitive match check via contains() (Module 2)
                if (cleanQuestion.contains(topic.toLowerCase())) {
                    topicCounts.put(topic, topicCounts.get(topic) + 1);
                }
            }
        }

        // Clean topics with zero count
        topicCounts.entrySet().removeIf(entry -> entry.getValue() == 0);

        return topicCounts;
    }

    /**
     * Generates a thread-safe formatted analytics summary text.
     * Demonstrates StringBuffer and String.valueOf() (Module 2).
     */
    public String generateAnalyticsSummaryReport() {
        StringBuffer sb = new StringBuffer(); // Thread-safe buffer
        sb.append("=== PORTAL ANALYTICS REPORT ===\n");
        sb.append("Total Experiences: ").append(String.valueOf(getTotalExperiences())).append("\n");
        sb.append("Selection Rate: ").append(String.valueOf(getSelectionRate())).append("%\n");
        
        sb.append("\nCompany Counts:\n");
        Map<String, Integer> companies = getCompanyExperienceCountsSorted();
        for (Map.Entry<String, Integer> entry : companies.entrySet()) {
            sb.append("- ").append(entry.getKey()).append(": ").append(String.valueOf(entry.getValue())).append("\n");
        }

        sb.append("\nFrequent Topics Identified:\n");
        Map<String, Integer> topics = getMostFrequentTopics();
        for (Map.Entry<String, Integer> entry : topics.entrySet()) {
            sb.append("- ").append(entry.getKey()).append(": ").append(String.valueOf(entry.getValue())).append(" mentions\n");
        }
        
        return sb.toString();
    }
}
