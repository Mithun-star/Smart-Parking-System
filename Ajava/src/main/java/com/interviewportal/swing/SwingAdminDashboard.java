package com.interviewportal.swing;

import com.interviewportal.model.InterviewExperience;
import com.interviewportal.model.User;
import com.interviewportal.service.AnalyticsService;
import com.interviewportal.service.ExperienceService;
import com.interviewportal.service.UserService;

import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.List;
import java.util.Map;

public class SwingAdminDashboard extends JFrame {
    private static final long serialVersionUID = 1L;

    // Services
    private final UserService userService = new UserService();
    private final ExperienceService experienceService = new ExperienceService();
    private final AnalyticsService analyticsService = new AnalyticsService();

    // Swing UI Components
    private JTable usersTable;
    private JTable experiencesTable;
    private DefaultTableModel usersTableModel;
    private DefaultTableModel experiencesTableModel;

    // Filter and stats inputs/labels
    private JTextField searchField;
    private JRadioButton viewUsersRadio;
    private JRadioButton viewExpsRadio;
    private JCheckBox confirmSafetyCheck;
    private JLabel totalUsersLabel;
    private JLabel totalExpsLabel;
    private JLabel selectionRateLabel;
    private JTextArea consoleReportArea;

    public SwingAdminDashboard() {
        super("PrepShare Portal - Swing Admin Dashboard");
        initializeUI();
    }

    private void initializeUI() {
        // Set Look and Feel to Nimbus if available for modern appearance
        try {
            for (UIManager.LookAndFeelInfo info : UIManager.getInstalledLookAndFeels()) {
                if ("Nimbus".equals(info.getName())) {
                    UIManager.setLookAndFeel(info.getClassName());
                    break;
                }
            }
        } catch (Exception ignored) {}

        // Main Layout config
        setSize(1000, 700);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null); // Center on screen
        setLayout(new BorderLayout(10, 10));

        // 1. Top Panel: Header & Stats Block
        JPanel topPanel = new JPanel(new GridLayout(1, 4, 10, 10));
        topPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        
        JPanel p1 = createStatCard("Total Active Users");
        totalUsersLabel = (JLabel) p1.getComponent(0);
        
        JPanel p2 = createStatCard("Experiences Contributed");
        totalExpsLabel = (JLabel) p2.getComponent(0);
        
        JPanel p3 = createStatCard("System Selection Rate");
        selectionRateLabel = (JLabel) p3.getComponent(0);
        
        JPanel p4 = new JPanel(new BorderLayout());
        p4.setBorder(BorderFactory.createTitledBorder("View Choice"));
        viewUsersRadio = new JRadioButton("Registered Users", true);
        viewExpsRadio = new JRadioButton("Interview Experiences", false);
        ButtonGroup group = new ButtonGroup();
        group.add(viewUsersRadio);
        group.add(viewExpsRadio);
        JPanel radioPanel = new JPanel(new GridLayout(2, 1));
        radioPanel.add(viewUsersRadio);
        radioPanel.add(viewExpsRadio);
        p4.add(radioPanel, BorderLayout.CENTER);

        topPanel.add(p1);
        topPanel.add(p2);
        topPanel.add(p3);
        topPanel.add(p4);
        add(topPanel, BorderLayout.NORTH);

        // 2. Center Panel: Split Pane for Tables & Report Console
        JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
        splitPane.setDividerLocation(650);

        // Tables Card Panel
        final CardLayout cardLayout = new CardLayout();
        final JPanel cards = new JPanel(cardLayout);

        // A. Users Table View
        usersTableModel = new DefaultTableModel(new String[]{"ID", "Username", "Email", "Full Name", "Created At"}, 0);
        usersTable = new JTable(usersTableModel);
        JScrollPane usersScroll = new JScrollPane(usersTable);
        cards.add(usersScroll, "USERS_CARD");

        // B. Experiences Table View
        experiencesTableModel = new DefaultTableModel(new String[]{"ID", "Author", "Company", "Role", "Rounds", "Difficulty", "Result"}, 0);
        experiencesTable = new JTable(experiencesTableModel);
        JScrollPane expsScroll = new JScrollPane(experiencesTable);
        cards.add(expsScroll, "EXPS_CARD");

        splitPane.setLeftComponent(cards);

        // C. Console Report Text Area
        JPanel rightPanel = new JPanel(new BorderLayout());
        rightPanel.setBorder(BorderFactory.createTitledBorder("System Console Summary"));
        consoleReportArea = new JTextArea();
        consoleReportArea.setEditable(false);
        consoleReportArea.setFont(new Font("Monospaced", Font.PLAIN, 12));
        consoleReportArea.setBackground(new Color(245, 245, 245));
        rightPanel.add(new JScrollPane(consoleReportArea), BorderLayout.CENTER);
        
        splitPane.setRightComponent(rightPanel);
        add(splitPane, BorderLayout.CENTER);

        // 3. Bottom Panel: Actions and Search Filter
        JPanel bottomPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 15, 10));
        bottomPanel.setBorder(BorderFactory.createEmptyBorder(5, 10, 10, 10));

        bottomPanel.add(new JLabel("Search filter (Company/Username):"));
        searchField = new JTextField(15);
        bottomPanel.add(searchField);

        JButton filterButton = new JButton("Filter Search");
        bottomPanel.add(filterButton);

        JButton refreshButton = new JButton("Refresh Dashboard");
        bottomPanel.add(refreshButton);

        confirmSafetyCheck = new JCheckBox("Confirm Deletion");
        bottomPanel.add(confirmSafetyCheck);

        JButton deleteButton = new JButton("Delete Selection");
        deleteButton.setBackground(Color.RED);
        deleteButton.setForeground(Color.WHITE);
        bottomPanel.add(deleteButton);

        add(bottomPanel, BorderLayout.SOUTH);

        // --- Event Handling and Listeners ---

        // Radio switches cards
        viewUsersRadio.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                cardLayout.show(cards, "USERS_CARD");
            }
        });

        viewExpsRadio.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                cardLayout.show(cards, "EXPS_CARD");
            }
        });

        // Refresh action
        refreshButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                loadStatsAndLogs();
            }
        });

        // Filter search action
        filterButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                applyFilter();
            }
        });

        // Delete action
        deleteButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                executeDeletion();
            }
        });

        // Initial Load
        loadStatsAndLogs();
    }

    private JPanel createStatCard(String labelText) {
        JPanel card = new JPanel(new BorderLayout());
        card.setBorder(BorderFactory.createTitledBorder(labelText));
        JLabel val = new JLabel("0", JLabel.CENTER);
        val.setFont(new Font("SansSerif", Font.BOLD, 22));
        val.setForeground(new Color(99, 102, 241));
        card.add(val, BorderLayout.CENTER);
        return card;
    }

    private void loadStatsAndLogs() {
        // Load metric counts
        int usersCount = userService.getAllUsers().size();
        int expsCount = analyticsService.getTotalExperiences();
        double selectionRate = analyticsService.getSelectionRate();

        totalUsersLabel.setText(String.valueOf(usersCount));
        totalExpsLabel.setText(String.valueOf(expsCount));
        selectionRateLabel.setText(selectionRate + "%");

        // Load Tables
        loadUsersTable(userService.getAllUsers());
        loadExperiencesTable(experienceService.getAllExperiences());

        // Load StringBuffer Console Report
        String report = analyticsService.generateAnalyticsSummaryReport();
        consoleReportArea.setText(report);
        
        confirmSafetyCheck.setSelected(false);
    }

    private void loadUsersTable(List<User> list) {
        usersTableModel.setRowCount(0);
        for (User u : list) {
            usersTableModel.addRow(new Object[]{
                    u.getId(),
                    u.getUsername(),
                    u.getEmail(),
                    u.getFullName(),
                    u.getCreatedAt()
            });
        }
    }

    private void loadExperiencesTable(List<InterviewExperience> list) {
        experiencesTableModel.setRowCount(0);
        for (InterviewExperience exp : list) {
            experiencesTableModel.addRow(new Object[]{
                    exp.getId(),
                    exp.getUsername(),
                    exp.getCompanyName(),
                    exp.getRole(),
                    exp.getRoundsCount(),
                    exp.getDifficultyLevel(),
                    exp.getResult()
            });
        }
    }

    private void applyFilter() {
        String filter = searchField.getText().trim().toLowerCase();
        
        if (viewUsersRadio.isSelected()) {
            List<User> list = userService.getAllUsers();
            list.removeIf(u -> !u.getUsername().toLowerCase().contains(filter) &&
                               !u.getFullName().toLowerCase().contains(filter));
            loadUsersTable(list);
        } else {
            List<InterviewExperience> list = experienceService.getAllExperiences();
            list.removeIf(exp -> !exp.getCompanyName().toLowerCase().contains(filter) &&
                                 !exp.getRole().toLowerCase().contains(filter));
            loadExperiencesTable(list);
        }
    }

    private void executeDeletion() {
        if (!confirmSafetyCheck.isSelected()) {
            JOptionPane.showMessageDialog(this, "Please check 'Confirm Deletion' to proceed.", "Safety Warning", JOptionPane.WARNING_MESSAGE);
            return;
        }

        if (viewUsersRadio.isSelected()) {
            int selectedRow = usersTable.getSelectedRow();
            if (selectedRow == -1) {
                JOptionPane.showMessageDialog(this, "Please select a user row to delete.", "Error", JOptionPane.ERROR_MESSAGE);
                return;
            }
            int userId = (int) usersTable.getValueAt(selectedRow, 0);
            String username = (String) usersTable.getValueAt(selectedRow, 1);

            int opt = JOptionPane.showConfirmDialog(this, "Are you sure you want to delete user: " + username + "? All their shared interview experiences will be permanently lost.", "Confirm Deletion", JOptionPane.YES_NO_OPTION);
            if (opt == JOptionPane.YES_OPTION) {
                boolean success = userService.deleteUser(userId);
                if (success) {
                    analyticsService.logEvent("SWING_DELETE_USER", "Swing admin deleted user: " + username);
                    JOptionPane.showMessageDialog(this, "User deleted successfully.");
                    loadStatsAndLogs();
                } else {
                    JOptionPane.showMessageDialog(this, "Failed to delete user. Check DB constraints.", "Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        } else {
            int selectedRow = experiencesTable.getSelectedRow();
            if (selectedRow == -1) {
                JOptionPane.showMessageDialog(this, "Please select an experience row to delete.", "Error", JOptionPane.ERROR_MESSAGE);
                return;
            }
            int expId = (int) experiencesTable.getValueAt(selectedRow, 0);
            String company = (String) experiencesTable.getValueAt(selectedRow, 2);

            int opt = JOptionPane.showConfirmDialog(this, "Are you sure you want to delete the experience for " + company + "?", "Confirm Deletion", JOptionPane.YES_NO_OPTION);
            if (opt == JOptionPane.YES_OPTION) {
                boolean success = experienceService.deleteExperience(expId);
                if (success) {
                    analyticsService.logEvent("SWING_DELETE_EXP", "Swing admin deleted experience ID: " + expId);
                    JOptionPane.showMessageDialog(this, "Experience deleted successfully.");
                    loadStatsAndLogs();
                } else {
                    JOptionPane.showMessageDialog(this, "Failed to delete experience.", "Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        }
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                new SwingAdminDashboard().setVisible(true);
            }
        });
    }
}
