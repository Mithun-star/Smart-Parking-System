package com.interviewportal.service;

import com.interviewportal.dao.InterviewExperienceDAO;
import com.interviewportal.model.InterviewExperience;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;

public class ExperienceService {
    private final InterviewExperienceDAO experienceDAO = new InterviewExperienceDAO();

    public boolean addExperience(InterviewExperience exp) {
        if (exp == null || exp.getCompanyName() == null || exp.getCompanyName().trim().isEmpty()) {
            return false;
        }
        // Normalize strings before inserting
        exp.setCompanyName(exp.getCompanyName().trim());
        exp.setRole(exp.getRole().trim());
        exp.setQuestionsAsked(exp.getQuestionsAsked().trim());
        if (exp.getTips() != null) {
            exp.setTips(exp.getTips().trim());
        }
        return experienceDAO.addExperience(exp);
    }

    public boolean updateExperience(InterviewExperience exp) {
        if (exp == null || exp.getId() <= 0) {
            return false;
        }
        exp.setCompanyName(exp.getCompanyName().trim());
        exp.setRole(exp.getRole().trim());
        exp.setQuestionsAsked(exp.getQuestionsAsked().trim());
        if (exp.getTips() != null) {
            exp.setTips(exp.getTips().trim());
        }
        return experienceDAO.updateExperience(exp);
    }

    public boolean deleteExperience(int id) {
        return experienceDAO.deleteExperience(id);
    }

    public InterviewExperience getExperienceById(int id) {
        return experienceDAO.getExperienceById(id);
    }

    public List<InterviewExperience> getExperiencesByUserId(int userId) {
        return experienceDAO.getExperiencesByUserId(userId);
    }

    public List<InterviewExperience> getAllExperiences() {
        return experienceDAO.getAllExperiences();
    }

    /**
     * Searches experiences and demonstrates String comparisons & manipulations (Module 2).
     */
    public List<InterviewExperience> searchExperiences(String company, String role, String difficulty, String result) {
        // Demonstrate string modifications before query
        String cleanCompany = (company != null) ? company.trim().toLowerCase() : "";
        String cleanRole = (role != null) ? role.trim().toLowerCase() : "";
        String cleanDifficulty = (difficulty != null) ? difficulty.trim() : "All";
        String cleanResult = (result != null) ? result.trim() : "All";

        // Query database
        List<InterviewExperience> rawList = experienceDAO.searchExperiences(cleanCompany, cleanRole, cleanDifficulty, cleanResult);
        
        // Demonstrate Iterator (Module 1) and contains() (Module 2) for custom client-side filter simulation
        List<InterviewExperience> filteredList = new ArrayList<>();
        Iterator<InterviewExperience> iterator = rawList.iterator();
        while (iterator.hasNext()) {
            InterviewExperience exp = iterator.next();
            // Client side validation using contains() and equalsIgnoreCase()
            if (exp.getCompanyName().toLowerCase().contains(cleanCompany) && 
                exp.getRole().toLowerCase().contains(cleanRole)) {
                
                // Truncate very long questions for preview using substring() (Module 2)
                String qAsked = exp.getQuestionsAsked();
                if (qAsked != null && qAsked.length() > 100) {
                    exp.setQuestionsAsked(qAsked.substring(0, 97) + "...");
                }
                filteredList.add(exp);
            }
        }
        return filteredList;
    }

    /**
     * Sorts interview experiences using Comparator and Collections.sort (Module 1).
     * @param criteria "date" or "rounds" or "difficulty"
     */
    public void sortExperiences(List<InterviewExperience> list, String criteria) {
        if (list == null || list.isEmpty() || criteria == null) return;

        if (criteria.equalsIgnoreCase("date")) {
            // Sort by interview date descending
            Collections.sort(list, new Comparator<InterviewExperience>() {
                @Override
                public int compare(InterviewExperience e1, InterviewExperience e2) {
                    if (e1.getInterviewDate() == null || e2.getInterviewDate() == null) return 0;
                    return e2.getInterviewDate().compareTo(e1.getInterviewDate());
                }
            });
        } else if (criteria.equalsIgnoreCase("rounds")) {
            // Sort by rounds count descending
            Collections.sort(list, new Comparator<InterviewExperience>() {
                @Override
                public int compare(InterviewExperience e1, InterviewExperience e2) {
                    return Integer.compare(e2.getRoundsCount(), e1.getRoundsCount());
                }
            });
        } else if (criteria.equalsIgnoreCase("difficulty")) {
            // Sort by difficulty: Hard -> Medium -> Easy
            Collections.sort(list, new Comparator<InterviewExperience>() {
                @Override
                public int compare(InterviewExperience e1, InterviewExperience e2) {
                    int weight1 = getDifficultyWeight(e1.getDifficultyLevel());
                    int weight2 = getDifficultyWeight(e2.getDifficultyLevel());
                    return Integer.compare(weight2, weight1);
                }

                private int getDifficultyWeight(String diff) {
                    if (diff == null) return 0;
                    if (diff.equalsIgnoreCase("Hard")) return 3;
                    if (diff.equalsIgnoreCase("Medium")) return 2;
                    if (diff.equalsIgnoreCase("Easy")) return 1;
                    return 0;
                }
            });
        }
    }

    /**
     * Demonstrates Collection Algorithms (Module 1).
     * Finds the experience with the maximum number of interview rounds.
     */
    public InterviewExperience getExperienceWithMaxRounds(List<InterviewExperience> list) {
        if (list == null || list.isEmpty()) return null;
        return Collections.max(list, new Comparator<InterviewExperience>() {
            @Override
            public int compare(InterviewExperience e1, InterviewExperience e2) {
                return Integer.compare(e1.getRoundsCount(), e2.getRoundsCount());
            }
        });
    }
}
