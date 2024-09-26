-- 1. Users
CREATE TABLE Users (
    user_id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id)
);

-- 2. Experiments
CREATE TABLE Experiments (
    experiment_id INT NOT NULL AUTO_INCREMENT,
    experiment_name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE,
    status ENUM('Active', 'Completed', 'Paused'),
    PRIMARY KEY (experiment_id)
);

-- 3. Variants
CREATE TABLE Variants (
    variant_id INT NOT NULL AUTO_INCREMENT,
    experiment_id INT NOT NULL,
    variant_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (variant_id),
    FOREIGN KEY (experiment_id) REFERENCES Experiments(experiment_id)
);

-- 4. User Assignments
CREATE TABLE UserAssignments (
    assignment_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    variant_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (assignment_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (variant_id) REFERENCES Variants(variant_id)
);

-- 5. Events
CREATE TABLE Events (
    event_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    experiment_id INT NOT NULL,
    event_type VARCHAR(50),
    event_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (experiment_id) REFERENCES Experiments(experiment_id)
);

-- 6. Goals
CREATE TABLE Goals (
    goal_id INT NOT NULL AUTO_INCREMENT,
    experiment_id INT NOT NULL,
    goal_description TEXT,
    PRIMARY KEY (goal_id),
    FOREIGN KEY (experiment_id) REFERENCES Experiments(experiment_id)
);

-- 7. Goal Metrics
CREATE TABLE GoalMetrics (
    metric_id INT NOT NULL AUTO_INCREMENT,
    goal_id INT NOT NULL,
    variant_id INT NOT NULL,
    conversion_count INT,
    PRIMARY KEY (metric_id),
    FOREIGN KEY (goal_id) REFERENCES Goals(goal_id),
    FOREIGN KEY (variant_id) REFERENCES Variants(variant_id)
);

-- 8. Feedback
CREATE TABLE Feedback (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    experiment_id INT NOT NULL,
    feedback_text TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (experiment_id) REFERENCES Experiments(experiment_id)
);

-- 9. Feature Flags
CREATE TABLE FeatureFlags (
    flag_id INT NOT NULL AUTO_INCREMENT,
    flag_name VARCHAR(100) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (flag_id)
);

-- 10. Flag Assignments
CREATE TABLE FlagAssignments (
    assignment_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    flag_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (assignment_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (flag_id) REFERENCES FeatureFlags(flag_id)
);

-- 11. Sessions
CREATE TABLE Sessions (
    session_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    PRIMARY KEY (session_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 12. Page Views
CREATE TABLE PageViews (
    view_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    session_id INT NOT NULL,
    page_url VARCHAR(255),
    view_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (view_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id)
);

-- 13. Clicks
CREATE TABLE Clicks (
    click_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    click_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (click_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- 14. Annotations
CREATE TABLE Annotations (
    annotation_id INT NOT NULL AUTO_INCREMENT,
    experiment_id INT NOT NULL,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (annotation_id),
    FOREIGN KEY (experiment_id) REFERENCES Experiments(experiment_id)
);

-- 15. Metrics
CREATE TABLE Metrics (
    metric_id INT NOT NULL AUTO_INCREMENT,
    experiment_id INT NOT NULL,
    metric_name VARCHAR(100),
    metric_value DECIMAL(10, 2),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (metric_id),
    FOREIGN KEY (experiment_id) REFERENCES Experiments(experiment_id)
);

-- 16. Cohorts
CREATE TABLE Cohorts (
    cohort_id INT NOT NULL AUTO_INCREMENT,
    cohort_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cohort_id)
);

-- 17. Cohort Members
CREATE TABLE CohortMembers (
    member_id INT NOT NULL AUTO_INCREMENT,
    cohort_id INT NOT NULL,
    user_id INT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (member_id),
    FOREIGN KEY (cohort_id) REFERENCES Cohorts(cohort_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 18. User Segments
CREATE TABLE UserSegments (
    segment_id INT NOT NULL AUTO_INCREMENT,
    segment_name VARCHAR(100),
    criteria TEXT,
    PRIMARY KEY (segment_id)
);

-- 19. Segment Memberships
CREATE TABLE SegmentMemberships (
    membership_id INT NOT NULL AUTO_INCREMENT,
    segment_id INT NOT NULL,
    user_id INT NOT NULL,
    PRIMARY KEY (membership_id),
    FOREIGN KEY (segment_id) REFERENCES UserSegments(segment_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 20. Notifications
CREATE TABLE Notifications (
    notification_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    message TEXT,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (notification_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 21. Test Plans
CREATE TABLE TestPlans (
    plan_id INT NOT NULL AUTO_INCREMENT,
    experiment_id INT NOT NULL,
    plan_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (plan_id),
    FOREIGN KEY (experiment_id) REFERENCES Experiments(experiment_id)
);

-- 22. Results
CREATE TABLE Results (
    result_id INT NOT NULL AUTO_INCREMENT,
    experiment_id INT NOT NULL,
    variant_id INT NOT NULL,
    total_users INT,
    conversion_rate DECIMAL(5, 2),
    PRIMARY KEY (result_id),
    FOREIGN KEY (experiment_id) REFERENCES Experiments(experiment_id),
    FOREIGN KEY (variant_id) REFERENCES Variants(variant_id)
);

-- 23. Rollouts
CREATE TABLE Rollouts (
    rollout_id INT NOT NULL AUTO_INCREMENT,
    feature_id INT NOT NULL,
    rollout_percentage INT CHECK (rollout_percentage BETWEEN 0 AND 100),
    rollout_date DATE,
    PRIMARY KEY (rollout_id),
    FOREIGN KEY (feature_id) REFERENCES FeatureFlags(flag_id)
);

-- 24. Development Tasks
CREATE TABLE DevelopmentTasks (
    task_id INT NOT NULL AUTO_INCREMENT,
    task_name VARCHAR(100),
    assigned_to INT,
    status ENUM('Pending', 'In Progress', 'Completed'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (task_id),
    FOREIGN KEY (assigned_to) REFERENCES Users(user_id)
);

-- 25. Task Comments
CREATE TABLE TaskComments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT,
    commented_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (task_id) REFERENCES DevelopmentTasks(task_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 26. Code Reviews
CREATE TABLE CodeReviews (
    review_id INT NOT NULL AUTO_INCREMENT,
    task_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Approved', 'Rejected'),
    PRIMARY KEY (review_id),
    FOREIGN KEY (task_id) REFERENCES DevelopmentTasks(task_id),
    FOREIGN KEY (reviewer_id) REFERENCES Users(user_id)
);

-- 27. Test Cases
CREATE TABLE TestCases (
    test_case_id INT NOT NULL AUTO_INCREMENT,
    task_id INT NOT NULL,
    test_description TEXT,
    expected_result TEXT,
    PRIMARY KEY (test_case_id),
    FOREIGN KEY (task_id) REFERENCES DevelopmentTasks(task_id)
);

-- 28. Test Results
CREATE TABLE TestResults (
    result_id INT NOT NULL AUTO_INCREMENT,
    test_case_id INT NOT NULL,
    status ENUM('Pass', 'Fail'),
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (result_id),
    FOREIGN KEY (test_case_id) REFERENCES TestCases(test_case_id)
);

-- 29. Releases
CREATE TABLE Releases (
    release_id INT NOT NULL AUTO_INCREMENT,
    version VARCHAR(20),
    release_date DATE,
    PRIMARY KEY (release_id)
);

-- 30. Release Notes
CREATE TABLE ReleaseNotes (
    note_id INT NOT NULL AUTO_INCREMENT,
    release_id INT NOT NULL,
    note TEXT,
    PRIMARY KEY (note_id),
    FOREIGN KEY (release_id) REFERENCES Releases(release_id)
);

-- 31. User Stories
CREATE TABLE UserStories (
    story_id INT NOT NULL AUTO_INCREMENT,
    description TEXT,
    acceptance_criteria TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (story_id)
);

-- 32. Story Assignments
CREATE TABLE StoryAssignments (
    assignment_id INT NOT NULL AUTO_INCREMENT,
    story_id INT NOT NULL,
    user_id INT NOT NULL,
    PRIMARY KEY (assignment_id),
    FOREIGN KEY (story_id) REFERENCES UserStories(story_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 33. Sprints
CREATE TABLE Sprints (
    sprint_id INT NOT NULL AUTO_INCREMENT,
    sprint_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (sprint_id)
);

-- 34. Sprint Tasks
CREATE TABLE SprintTasks (
    sprint_task_id INT NOT NULL AUTO_INCREMENT,
    sprint_id INT NOT NULL,
    task_id INT NOT NULL,
    PRIMARY KEY (sprint_task_id),
    FOREIGN KEY (sprint_id) REFERENCES Sprints(sprint_id),
    FOREIGN KEY (task_id) REFERENCES DevelopmentTasks(task_id)
);

-- 35. Backlogs
CREATE TABLE Backlogs (
    backlog_id INT NOT NULL AUTO_INCREMENT,
    sprint_id INT NOT NULL,
    task_id INT NOT NULL,
    PRIMARY KEY (backlog_id),
    FOREIGN KEY (sprint_id) REFERENCES Sprints(sprint_id),
    FOREIGN KEY (task_id) REFERENCES DevelopmentTasks(task_id)
);

-- 36. QA Teams
CREATE TABLE QATeams (
    qa_team_id INT NOT NULL AUTO_INCREMENT,
    team_name VARCHAR(100),
    PRIMARY KEY (qa_team_id)
);

-- 37. QA Assignments
CREATE TABLE QAAssignments (
    qa_assignment_id INT NOT NULL AUTO_INCREMENT,
    qa_team_id INT NOT NULL,
    user_id INT NOT NULL,
    PRIMARY KEY (qa_assignment_id),
    FOREIGN KEY (qa_team_id) REFERENCES QATeams(qa_team_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 38. QA Reports
CREATE TABLE QAReports (
    report_id INT NOT NULL AUTO_INCREMENT,
    qa_assignment_id INT NOT NULL,
    report_text TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (report_id),
    FOREIGN KEY (qa_assignment_id) REFERENCES QAAssignments(qa_assignment_id)
);

-- 39. Integration Tests
CREATE TABLE IntegrationTests (
    test_id INT NOT NULL AUTO_INCREMENT,
    test_description TEXT,
    expected_outcome TEXT,
    PRIMARY KEY (test_id)
);

-- 40. Integration Results
CREATE TABLE IntegrationResults (
    result_id INT NOT NULL AUTO_INCREMENT,
    test_id INT NOT NULL,
    status ENUM('Pass', 'Fail'),
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (result_id),
    FOREIGN KEY (test_id) REFERENCES IntegrationTests(test_id)
);

-- 41. Performance Tests
CREATE TABLE PerformanceTests (
    performance_test_id INT NOT NULL AUTO_INCREMENT,
    test_description TEXT,
    expected_performance TEXT,
    PRIMARY KEY (performance_test_id)
);

-- 42. Performance Results
CREATE TABLE PerformanceResults (
    result_id INT NOT NULL AUTO_INCREMENT,
    performance_test_id INT NOT NULL,
    status ENUM('Pass', 'Fail'),
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (result_id),
    FOREIGN KEY (performance_test_id) REFERENCES PerformanceTests(performance_test_id)
);

-- 43. Documentation
CREATE TABLE Documentation (
    doc_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(100),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (doc_id)
);

-- 44. API Endpoints
CREATE TABLE ApiEndpoints (
    endpoint_id INT NOT NULL AUTO_INCREMENT,
    endpoint_name VARCHAR(255),
    method ENUM('GET', 'POST', 'PUT', 'DELETE'),
    PRIMARY KEY (endpoint_id)
);

-- 45. API Logs
CREATE TABLE ApiLogs (
    log_id INT NOT NULL AUTO_INCREMENT,
    endpoint_id INT NOT NULL,
    request_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    response_status INT,
    PRIMARY KEY (log_id),
    FOREIGN KEY (endpoint_id) REFERENCES ApiEndpoints(endpoint_id)
);

-- 46. System Metrics
CREATE TABLE SystemMetrics (
    metric_id INT NOT NULL AUTO_INCREMENT,
    metric_name VARCHAR(100),
    metric_value DECIMAL(10, 2),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (metric_id)
);

-- 47. Load Tests
CREATE TABLE LoadTests (
    load_test_id INT NOT NULL AUTO_INCREMENT,
    test_description TEXT,
    expected_load TEXT,
    PRIMARY KEY (load_test_id)
);

-- 48. Load Test Results
CREATE TABLE LoadTestResults (
    result_id INT NOT NULL AUTO_INCREMENT,
    load_test_id INT NOT NULL,
    status ENUM('Pass', 'Fail'),
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (result_id),
    FOREIGN KEY (load_test_id) REFERENCES LoadTests(load_test_id)
);

-- 49. Security Tests
CREATE TABLE SecurityTests (
    security_test_id INT NOT NULL AUTO_INCREMENT,
    test_description TEXT,
    expected_outcome TEXT,
    PRIMARY KEY (security_test_id)
);

-- 50. Security Test Results
CREATE TABLE SecurityTestResults (
    result_id INT NOT NULL AUTO_INCREMENT,
    security_test_id INT NOT NULL,
    status ENUM('Pass', 'Fail'),
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (result_id),
    FOREIGN KEY (security_test_id) REFERENCES SecurityTests(security_test_id)
);

-- 51. Risk Assessments
CREATE TABLE RiskAssessments (
    assessment_id INT NOT NULL AUTO_INCREMENT,
    risk_description TEXT,
    mitigation_strategy TEXT,
    assessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (assessment_id)
);

-- 52. Audit Trails
CREATE TABLE AuditTrails (
    trail_id INT NOT NULL AUTO_INCREMENT,
    action TEXT,
    performed_by INT NOT NULL,
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (trail_id),
    FOREIGN KEY (performed_by) REFERENCES Users(user_id)
);

-- 53. Collaboration Tools
CREATE TABLE CollaborationTools (
    tool_id INT NOT NULL AUTO_INCREMENT,
    tool_name VARCHAR(100),
    PRIMARY KEY (tool_id)
);

-- 54. Tool Integrations
CREATE TABLE ToolIntegrations (
    integration_id INT NOT NULL AUTO_INCREMENT,
    tool_id INT NOT NULL,
    user_id INT NOT NULL,
    PRIMARY KEY (integration_id),
    FOREIGN KEY (tool_id) REFERENCES CollaborationTools(tool_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 55. User Engagements
CREATE TABLE UserEngagements (
    engagement_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    engagement_type VARCHAR(100),
    engagement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (engagement_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 56. Change Requests
CREATE TABLE ChangeRequests (
    request_id INT NOT NULL AUTO_INCREMENT,
    description TEXT,
    status ENUM('Pending', 'Approved', 'Rejected'),
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (request_id)
);

-- 57. Change Request Approvals
CREATE TABLE ChangeRequestApprovals (
    approval_id INT NOT NULL AUTO_INCREMENT,
    request_id INT NOT NULL,
    approved_by INT NOT NULL,
    approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (approval_id),
    FOREIGN KEY (request_id) REFERENCES ChangeRequests(request_id),
    FOREIGN KEY (approved_by) REFERENCES Users(user_id)
);

-- 58. Training Sessions
CREATE TABLE TrainingSessions (
    session_id INT NOT NULL AUTO_INCREMENT,
    topic VARCHAR(100),
    scheduled_at TIMESTAMP,
    PRIMARY KEY (session_id)
);

-- 59. Training Attendance
CREATE TABLE TrainingAttendance (
    attendance_id INT NOT NULL AUTO_INCREMENT,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    attended BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (attendance_id),
    FOREIGN KEY (session_id) REFERENCES TrainingSessions(session_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 60. User Satisfaction Surveys
CREATE TABLE UserSatisfactionSurveys (
    survey_id INT NOT NULL AUTO_INCREMENT,
    survey_title VARCHAR(100),
    submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (survey_id)
);

-- 61. Survey Responses
CREATE TABLE SurveyResponses (
    response_id INT NOT NULL AUTO_INCREMENT,
    survey_id INT NOT NULL,
    user_id INT NOT NULL,
    response_text TEXT,
    PRIMARY KEY (response_id),
    FOREIGN KEY (survey_id) REFERENCES UserSatisfactionSurveys(survey_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 62. Analytics
CREATE TABLE Analytics (
    analytics_id INT NOT NULL AUTO_INCREMENT,
    experiment_id INT NOT NULL,
    metric_name VARCHAR(100),
    metric_value DECIMAL(10, 2),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (analytics_id),
    FOREIGN KEY (experiment_id) REFERENCES Experiments(experiment_id)
);

-- 63. Product Backlog
CREATE TABLE ProductBacklog (
    backlog_id INT NOT NULL AUTO_INCREMENT,
    item_description TEXT,
    priority ENUM('Low', 'Medium', 'High'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (backlog_id)
);

-- 64. Backlog Refinements
CREATE TABLE BacklogRefinements (
    refinement_id INT NOT NULL AUTO_INCREMENT,
    backlog_id INT NOT NULL,
    refined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (refinement_id),
    FOREIGN KEY (backlog_id) REFERENCES ProductBacklog(backlog_id)
);

-- 65. Product Roadmaps
CREATE TABLE ProductRoadmaps (
    roadmap_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (roadmap_id)
);

-- 66. Roadmap Items
CREATE TABLE RoadmapItems (
    item_id INT NOT NULL AUTO_INCREMENT,
    roadmap_id INT NOT NULL,
    description TEXT,
    due_date DATE,
    PRIMARY KEY (item_id),
    FOREIGN KEY (roadmap_id) REFERENCES ProductRoadmaps(roadmap_id)
);

-- 67. Incident Reports
CREATE TABLE IncidentReports (
    report_id INT NOT NULL AUTO_INCREMENT,
    incident_description TEXT,
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (report_id)
);

-- 68. Incident Resolutions
CREATE TABLE IncidentResolutions (
    resolution_id INT NOT NULL AUTO_INCREMENT,
    report_id INT NOT NULL,
    resolution_description TEXT,
    resolved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (resolution_id),
    FOREIGN KEY (report_id) REFERENCES IncidentReports(report_id)
);

-- 69. Communication Logs
CREATE TABLE CommunicationLogs (
    log_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    communication_type VARCHAR(100),
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 70. External Collaborations
CREATE TABLE ExternalCollaborations (
    collaboration_id INT NOT NULL AUTO_INCREMENT,
    company_name VARCHAR(100),
    contact_person VARCHAR(100),
    PRIMARY KEY (collaboration_id)
);

-- 71. Collaboration Notes
CREATE TABLE CollaborationNotes (
    note_id INT NOT NULL AUTO_INCREMENT,
    collaboration_id INT NOT NULL,
    note_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (note_id),
    FOREIGN KEY (collaboration_id) REFERENCES ExternalCollaborations(collaboration_id)
);

-- 72. Retrospectives
CREATE TABLE Retrospectives (
    retrospective_id INT NOT NULL AUTO_INCREMENT,
    session_id INT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (retrospective_id),
    FOREIGN KEY (session_id) REFERENCES TrainingSessions(session_id)
);

-- 73. Performance Reviews
CREATE TABLE PerformanceReviews2 (
    review_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    review_period VARCHAR(50),
    comments TEXT,
    PRIMARY KEY (review_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 74. User Roles
CREATE TABLE UserRoles (
    role_id INT NOT NULL AUTO_INCREMENT,
    role_name VARCHAR(50),
    PRIMARY KEY (role_id)
);

-- 75. User Role Assignments
CREATE TABLE UserRoleAssignments (
    assignment_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (assignment_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (role_id) REFERENCES UserRoles(role_id)
);

-- 76. API Keys
CREATE TABLE ApiKeys (
    api_key_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    key_value VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (api_key_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 77. Deployment Logs
CREATE TABLE DeploymentLogs (
    log_id INT NOT NULL AUTO_INCREMENT,
    deployment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    PRIMARY KEY (log_id)
);

-- 78. Technical Debt
CREATE TABLE TechnicalDebt (
    debt_id INT NOT NULL AUTO_INCREMENT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (debt_id)
);

-- 79. Debt Resolutions
CREATE TABLE DebtResolutions (
    resolution_id INT NOT NULL AUTO_INCREMENT,
    debt_id INT NOT NULL,
    resolution_description TEXT,
    resolved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (resolution_id),
    FOREIGN KEY (debt_id) REFERENCES TechnicalDebt(debt_id)
);

-- 80. Architecture Reviews
CREATE TABLE ArchitectureReviews (
    review_id INT NOT NULL AUTO_INCREMENT,
    description TEXT,
    reviewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id)
);

-- 81. Technical Specifications
CREATE TABLE TechnicalSpecifications (
    spec_id INT NOT NULL AUTO_INCREMENT,
    project_name VARCHAR(100),
    spec_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (spec_id)
);

-- 82. Technology Stack
CREATE TABLE TechnologyStack (
    stack_id INT NOT NULL AUTO_INCREMENT,
    technology_name VARCHAR(100),
    PRIMARY KEY (stack_id)
);

-- 83. Stack Components
CREATE TABLE StackComponents (
    component_id INT NOT NULL AUTO_INCREMENT,
    stack_id INT NOT NULL,
    component_name VARCHAR(100),
    PRIMARY KEY (component_id),
    FOREIGN KEY (stack_id) REFERENCES TechnologyStack(stack_id)
);

-- 84. Stakeholders
CREATE TABLE Stakeholders (
    stakeholder_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    PRIMARY KEY (stakeholder_id)
);

-- 85. Stakeholder Feedback
CREATE TABLE StakeholderFeedback (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    stakeholder_id INT NOT NULL,
    feedback_text TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (stakeholder_id) REFERENCES Stakeholders(stakeholder_id)
);

-- 86. Meeting Notes
CREATE TABLE MeetingNotes (
    note_id INT NOT NULL AUTO_INCREMENT,
    meeting_date TIMESTAMP,
    notes TEXT,
    PRIMARY KEY (note_id)
);

-- 87. Project Timelines
CREATE TABLE ProjectTimelines (
    timeline_id INT NOT NULL AUTO_INCREMENT,
    project_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (timeline_id)
);

-- 88. Milestones
CREATE TABLE Milestones (
    milestone_id INT NOT NULL AUTO_INCREMENT,
    timeline_id INT NOT NULL,
    milestone_description TEXT,
    milestone_date DATE,
    PRIMARY KEY (milestone_id),
    FOREIGN KEY (timeline_id) REFERENCES ProjectTimelines(timeline_id)
);

-- 89. Risk Mitigation Plans
CREATE TABLE RiskMitigationPlans (
    plan_id INT NOT NULL AUTO_INCREMENT,
    risk_id INT NOT NULL,
    mitigation_strategy TEXT,
    PRIMARY KEY (plan_id),
    FOREIGN KEY (risk_id) REFERENCES RiskAssessments(assessment_id)
);

-- 90. User Groups
CREATE TABLE UserGroups (
    group_id INT NOT NULL AUTO_INCREMENT,
    group_name VARCHAR(100),
    PRIMARY KEY (group_id)
);

-- 91. Group Memberships
CREATE TABLE GroupMemberships (
    membership_id INT NOT NULL AUTO_INCREMENT,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    PRIMARY KEY (membership_id),
    FOREIGN KEY (group_id) REFERENCES UserGroups(group_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 92. User Notifications
CREATE TABLE UserNotifications (
    notification_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    notification_text TEXT,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (notification_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 93. User Preferences
CREATE TABLE UserPreferences (
    preference_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    preference_key VARCHAR(100),
    preference_value VARCHAR(255),
    PRIMARY KEY (preference_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 94. Data Privacy Agreements
CREATE TABLE DataPrivacyAgreements (
    agreement_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    agreement_text TEXT,
    signed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (agreement_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 95. Compliance Checklists
CREATE TABLE ComplianceChecklists (
    checklist_id INT NOT NULL AUTO_INCREMENT,
    checklist_name VARCHAR(100),
    PRIMARY KEY (checklist_id)
);

-- 96. Checklist Items
CREATE TABLE ChecklistItems (
    item_id INT NOT NULL AUTO_INCREMENT,
    checklist_id INT NOT NULL,
    item_description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (item_id),
    FOREIGN KEY (checklist_id) REFERENCES ComplianceChecklists(checklist_id)
);

-- 97. Knowledge Base Articles
CREATE TABLE KnowledgeBaseArticles (
    article_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(100),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (article_id)
);

-- 98. Article Feedback
CREATE TABLE ArticleFeedback (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    article_id INT NOT NULL,
    user_id INT NOT NULL,
    feedback_text TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (article_id) REFERENCES KnowledgeBaseArticles(article_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 99. Roadmap Feedback
CREATE TABLE RoadmapFeedback (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    roadmap_id INT NOT NULL,
    user_id INT NOT NULL,
    feedback_text TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (roadmap_id) REFERENCES ProductRoadmaps(roadmap_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 100. Project Status
CREATE TABLE ProjectStatus (
    status_id INT NOT NULL AUTO_INCREMENT,
    project_name VARCHAR(100),
    status ENUM('On Track', 'At Risk', 'Delayed'),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (status_id)
);

-- 1. Employees
CREATE TABLE Employees (
    employee_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    hire_date DATE,
    job_title VARCHAR(50),
    salary DECIMAL(10, 2),
    PRIMARY KEY (employee_id)
);

-- 2. Departments
CREATE TABLE Departments (
    department_id INT NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    PRIMARY KEY (department_id)
);

-- 3. Projects
CREATE TABLE Projects (
    project_id INT NOT NULL AUTO_INCREMENT,
    project_name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10, 2),
    PRIMARY KEY (project_id)
);

-- 4. Employee Departments
CREATE TABLE EmployeeDepartments (
    emp_dept_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    department_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (emp_dept_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- 5. Project Assignments
CREATE TABLE ProjectAssignments (
    assignment_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    project_id INT NOT NULL,
    role VARCHAR(50),
    PRIMARY KEY (assignment_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

-- 6. Salaries
CREATE TABLE Salaries (
    salary_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    salary_amount DECIMAL(10, 2) NOT NULL,
    pay_date DATE,
    PRIMARY KEY (salary_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 7. Performance Reviews
CREATE TABLE PerformanceReviews (
    review_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    review_date DATE,
    score INT CHECK (score BETWEEN 1 AND 5),
    comments TEXT,
    PRIMARY KEY (review_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 8. Attendance
CREATE TABLE Attendance (
    attendance_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    attendance_date DATE,
    status ENUM('Present', 'Absent', 'Leave'),
    PRIMARY KEY (attendance_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 9. Expenses
CREATE TABLE Expenses (
    expense_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    expense_amount DECIMAL(10, 2),
    expense_date DATE,
    description TEXT,
    PRIMARY KEY (expense_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 10. Clients
CREATE TABLE Clients (
    client_id INT NOT NULL AUTO_INCREMENT,
    client_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    PRIMARY KEY (client_id)
);

-- 11. Invoices
CREATE TABLE Invoices (
    invoice_id INT NOT NULL AUTO_INCREMENT,
    client_id INT NOT NULL,
    invoice_date DATE,
    amount DECIMAL(10, 2),
    status ENUM('Paid', 'Pending', 'Overdue'),
    PRIMARY KEY (invoice_id),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id)
);

-- 12. Payments
CREATE TABLE Payments (
    payment_id INT NOT NULL AUTO_INCREMENT,
    invoice_id INT NOT NULL,
    payment_date DATE,
    amount DECIMAL(10, 2),
    PRIMARY KEY (payment_id),
    FOREIGN KEY (invoice_id) REFERENCES Invoices(invoice_id)
);

-- 13. Suppliers
CREATE TABLE Suppliers (
    supplier_id INT NOT NULL AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    PRIMARY KEY (supplier_id)
);

-- 14. Purchases
CREATE TABLE Purchases (
    purchase_id INT NOT NULL AUTO_INCREMENT,
    supplier_id INT NOT NULL,
    purchase_date DATE,
    total_amount DECIMAL(10, 2),
    PRIMARY KEY (purchase_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- 15. Products
CREATE TABLE Products (
    product_id INT NOT NULL AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (product_id)
);

-- 16. Inventory
CREATE TABLE Inventory (
    inventory_id INT NOT NULL AUTO_INCREMENT,
    product_id INT NOT NULL,
    stock_level INT,
    last_updated DATE,
    PRIMARY KEY (inventory_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 17. Meetings
CREATE TABLE Meetings (
    meeting_id INT NOT NULL AUTO_INCREMENT,
    meeting_date DATE,
    agenda TEXT,
    PRIMARY KEY (meeting_id)
);

-- 18. Meeting Participants
CREATE TABLE MeetingParticipants (
    participant_id INT NOT NULL AUTO_INCREMENT,
    meeting_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (participant_id),
    FOREIGN KEY (meeting_id) REFERENCES Meetings(meeting_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 19. Training Programs
CREATE TABLE TrainingPrograms (
    training_id INT NOT NULL AUTO_INCREMENT,
    program_name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (training_id)
);

-- 20. Employee Training
CREATE TABLE EmployeeTraining (
    training_participation_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    training_id INT NOT NULL,
    PRIMARY KEY (training_participation_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (training_id) REFERENCES TrainingPrograms(training_id)
);

-- 21. Policies
CREATE TABLE Policies (
    policy_id INT NOT NULL AUTO_INCREMENT,
    policy_name VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (policy_id)
);

-- 22. Policy Acknowledgments
CREATE TABLE PolicyAcknowledgments (
    acknowledgment_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    policy_id INT NOT NULL,
    acknowledgment_date DATE,
    PRIMARY KEY (acknowledgment_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (policy_id) REFERENCES Policies(policy_id)
);

-- 23. Company Assets
CREATE TABLE CompanyAssets (
    asset_id INT NOT NULL AUTO_INCREMENT,
    asset_name VARCHAR(100) NOT NULL,
    purchase_date DATE,
    value DECIMAL(10, 2),
    PRIMARY KEY (asset_id)
);

-- 24. Asset Allocation
CREATE TABLE AssetAllocation (
    allocation_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    asset_id INT NOT NULL,
    allocation_date DATE,
    PRIMARY KEY (allocation_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (asset_id) REFERENCES CompanyAssets(asset_id)
);

-- 25. Customer Feedback
CREATE TABLE CustomerFeedback (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    client_id INT NOT NULL,
    feedback_text TEXT,
    feedback_date DATE,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id)
);

-- 26. Marketing Campaigns
CREATE TABLE MarketingCampaigns (
    campaign_id INT NOT NULL AUTO_INCREMENT,
    campaign_name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10, 2),
    PRIMARY KEY (campaign_id)
);

-- 27. Campaign Performance
CREATE TABLE CampaignPerformance (
    performance_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    performance_metric VARCHAR(100),
    value DECIMAL(10, 2),
    PRIMARY KEY (performance_id),
    FOREIGN KEY (campaign_id) REFERENCES MarketingCampaigns(campaign_id)
);

-- 28. Contracts
CREATE TABLE Contracts (
    contract_id INT NOT NULL AUTO_INCREMENT,
    client_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    contract_value DECIMAL(10, 2),
    PRIMARY KEY (contract_id),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id)
);

-- 29. Audit Logs
CREATE TABLE AuditLogs (
    log_id INT NOT NULL AUTO_INCREMENT,
    action VARCHAR(100),
    timestamp DATETIME,
    employee_id INT NOT NULL,
    PRIMARY KEY (log_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 30. Risk Management
CREATE TABLE RiskManagement (
    risk_id INT NOT NULL AUTO_INCREMENT,
    description TEXT,
    assessment_date DATE,
    risk_level ENUM('Low', 'Medium', 'High'),
    PRIMARY KEY (risk_id)
);

-- 31. Risk Mitigation
CREATE TABLE RiskMitigation (
    mitigation_id INT NOT NULL AUTO_INCREMENT,
    risk_id INT NOT NULL,
    action_taken TEXT,
    implementation_date DATE,
    PRIMARY KEY (mitigation_id),
    FOREIGN KEY (risk_id) REFERENCES RiskManagement(risk_id)
);

-- 32. Business Continuity Plans
CREATE TABLE BusinessContinuityPlans (
    plan_id INT NOT NULL AUTO_INCREMENT,
    plan_name VARCHAR(100) NOT NULL,
    created_date DATE,
    PRIMARY KEY (plan_id)
);

-- 33. Plan Testing
CREATE TABLE PlanTesting (
    test_id INT NOT NULL AUTO_INCREMENT,
    plan_id INT NOT NULL,
    test_date DATE,
    results TEXT,
    PRIMARY KEY (test_id),
    FOREIGN KEY (plan_id) REFERENCES BusinessContinuityPlans(plan_id)
);

-- 34. Social Media Accounts
CREATE TABLE SocialMediaAccounts (
    account_id INT NOT NULL AUTO_INCREMENT,
    platform VARCHAR(50),
    handle VARCHAR(100),
    PRIMARY KEY (account_id)
);

-- 35. Social Media Posts
CREATE TABLE SocialMediaPosts (
    post_id INT NOT NULL AUTO_INCREMENT,
    account_id INT NOT NULL,
    content TEXT,
    post_date DATE,
    PRIMARY KEY (post_id),
    FOREIGN KEY (account_id) REFERENCES SocialMediaAccounts(account_id)
);

-- 36. Supplier Contracts
CREATE TABLE SupplierContracts (
    contract_id INT NOT NULL AUTO_INCREMENT,
    supplier_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    contract_value DECIMAL(10, 2),
    PRIMARY KEY (contract_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- 37. EventsVT
CREATE TABLE EventsVT (
    event_id INT NOT NULL AUTO_INCREMENT,
    event_name VARCHAR(100),
    event_date DATE,
    location VARCHAR(100),
    PRIMARY KEY (event_id)
);

-- 38. Event Participants
CREATE TABLE EventParticipants (
    participant_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (participant_id),
    FOREIGN KEY (event_id) REFERENCES EventsVT(event_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 39. Market Research
CREATE TABLE MarketResearch (
    research_id INT NOT NULL AUTO_INCREMENT,
    research_topic VARCHAR(100),
    findings TEXT,
    research_date DATE,
    PRIMARY KEY (research_id)
);

-- 40. Company Policies
CREATE TABLE CompanyPolicies (
    policy_id INT NOT NULL AUTO_INCREMENT,
    policy_name VARCHAR(100),
    description TEXT,
    PRIMARY KEY (policy_id)
);

-- 41. Employee Complaints
CREATE TABLE EmployeeComplaints (
    complaint_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    complaint_text TEXT,
    complaint_date DATE,
    PRIMARY KEY (complaint_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 42. Employee Benefits
CREATE TABLE EmployeeBenefits (
    benefit_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    benefit_type VARCHAR(100),
    PRIMARY KEY (benefit_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 43. User Accounts
CREATE TABLE UserAccounts (
    user_id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    employee_id INT,
    PRIMARY KEY (user_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 44. Password Resets
CREATE TABLE PasswordResets (
    reset_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    reset_date DATE,
    PRIMARY KEY (reset_id),
    FOREIGN KEY (user_id) REFERENCES UserAccounts(user_id)
);

-- 45. IT Assets
CREATE TABLE ITAssets (
    asset_id INT NOT NULL AUTO_INCREMENT,
    asset_name VARCHAR(100),
    purchase_date DATE,
    value DECIMAL(10, 2),
    PRIMARY KEY (asset_id)
);

-- 46. IT Support Tickets
CREATE TABLE ITSupportTickets (
    ticket_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    issue_description TEXT,
    submission_date DATE,
    status ENUM('Open', 'In Progress', 'Resolved'),
    PRIMARY KEY (ticket_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 47. Vendor Management
CREATE TABLE VendorManagement (
    vendor_id INT NOT NULL AUTO_INCREMENT,
    vendor_name VARCHAR(100),
    contact_person VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    PRIMARY KEY (vendor_id)
);

-- 48. Purchase Orders
CREATE TABLE PurchaseOrders (
    order_id INT NOT NULL AUTO_INCREMENT,
    supplier_id INT NOT NULL,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    PRIMARY KEY (order_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- 49. Sales
CREATE TABLE Sales (
    sale_id INT NOT NULL AUTO_INCREMENT,
    product_id INT NOT NULL,
    sale_date DATE,
    quantity INT,
    total_amount DECIMAL(10, 2),
    PRIMARY KEY (sale_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 50. Sales Reports
CREATE TABLE SalesReports (
    report_id INT NOT NULL AUTO_INCREMENT,
    report_date DATE,
    total_sales DECIMAL(10, 2),
    PRIMARY KEY (report_id)
);

-- 51. Financial Reports
CREATE TABLE FinancialReports (
    report_id INT NOT NULL AUTO_INCREMENT,
    report_date DATE,
    total_revenue DECIMAL(10, 2),
    total_expenses DECIMAL(10, 2),
    net_profit DECIMAL(10, 2),
    PRIMARY KEY (report_id)
);

-- 52. Business Goals
CREATE TABLE BusinessGoals (
    goal_id INT NOT NULL AUTO_INCREMENT,
    goal_description TEXT,
    target_date DATE,
    PRIMARY KEY (goal_id)
);

-- 53. Goal Progress
CREATE TABLE GoalProgress (
    progress_id INT NOT NULL AUTO_INCREMENT,
    goal_id INT NOT NULL,
    progress_percentage INT CHECK (progress_percentage BETWEEN 0 AND 100),
    PRIMARY KEY (progress_id),
    FOREIGN KEY (goal_id) REFERENCES BusinessGoals(goal_id)
);

-- 54. User Roles
CREATE TABLE UserRolesVT (
    role_id INT NOT NULL AUTO_INCREMENT,
    role_name VARCHAR(100),
    PRIMARY KEY (role_id)
);

-- 55. Role Assignments
CREATE TABLE RoleAssignments (
    assignment_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (assignment_id),
    FOREIGN KEY (user_id) REFERENCES UserAccounts(user_id),
    FOREIGN KEY (role_id) REFERENCES UserRolesVT(role_id)
);

-- 56. Feedback Forms
CREATE TABLE FeedbackForms (
    form_id INT NOT NULL AUTO_INCREMENT,
    form_title VARCHAR(100),
    submission_date DATE,
    PRIMARY KEY (form_id)
);

-- 57. Feedback Responses
CREATE TABLE FeedbackResponses (
    response_id INT NOT NULL AUTO_INCREMENT,
    form_id INT NOT NULL,
    employee_id INT NOT NULL,
    response_text TEXT,
    PRIMARY KEY (response_id),
    FOREIGN KEY (form_id) REFERENCES FeedbackForms(form_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 58. Document Management
CREATE TABLE DocumentManagement (
    document_id INT NOT NULL AUTO_INCREMENT,
    document_name VARCHAR(100),
    upload_date DATE,
    employee_id INT,
    PRIMARY KEY (document_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 59. Legal Documents
CREATE TABLE LegalDocuments (
    document_id INT NOT NULL AUTO_INCREMENT,
    document_name VARCHAR(100),
    upload_date DATE,
    PRIMARY KEY (document_id)
);

-- 60. Compliance Audits
CREATE TABLE ComplianceAudits (
    audit_id INT NOT NULL AUTO_INCREMENT,
    audit_date DATE,
    findings TEXT,
    PRIMARY KEY (audit_id)
);

-- 61. Audit Recommendations
CREATE TABLE AuditRecommendations (
    recommendation_id INT NOT NULL AUTO_INCREMENT,
    audit_id INT NOT NULL,
    recommendation_text TEXT,
    PRIMARY KEY (recommendation_id),
    FOREIGN KEY (audit_id) REFERENCES ComplianceAudits(audit_id)
);

-- 62. Tax Filings
CREATE TABLE TaxFilings (
    filing_id INT NOT NULL AUTO_INCREMENT,
    filing_year INT NOT NULL,
    amount DECIMAL(10, 2),
    filing_date DATE,
    PRIMARY KEY (filing_id)
);

-- 63. Payment Methods
CREATE TABLE PaymentMethods (
    method_id INT NOT NULL AUTO_INCREMENT,
    method_name VARCHAR(100),
    PRIMARY KEY (method_id)
);

-- 64. Payment Transactions
CREATE TABLE PaymentTransactions (
    transaction_id INT NOT NULL AUTO_INCREMENT,
    method_id INT NOT NULL,
    amount DECIMAL(10, 2),
    transaction_date DATE,
    PRIMARY KEY (transaction_id),
    FOREIGN KEY (method_id) REFERENCES PaymentMethods(method_id)
);

-- 65. Business Units
CREATE TABLE BusinessUnits (
    unit_id INT NOT NULL AUTO_INCREMENT,
    unit_name VARCHAR(100),
    PRIMARY KEY (unit_id)
);

-- 66. Unit Budgets
CREATE TABLE UnitBudgets (
    budget_id INT NOT NULL AUTO_INCREMENT,
    unit_id INT NOT NULL,
    budget_amount DECIMAL(10, 2),
    PRIMARY KEY (budget_id),
    FOREIGN KEY (unit_id) REFERENCES BusinessUnits(unit_id)
);

-- 67. Strategic Initiatives
CREATE TABLE StrategicInitiatives (
    initiative_id INT NOT NULL AUTO_INCREMENT,
    initiative_name VARCHAR(100),
    description TEXT,
    PRIMARY KEY (initiative_id)
);

-- 68. Initiative Progress
CREATE TABLE InitiativeProgress (
    progress_id INT NOT NULL AUTO_INCREMENT,
    initiative_id INT NOT NULL,
    progress_percentage INT CHECK (progress_percentage BETWEEN 0 AND 100),
    PRIMARY KEY (progress_id),
    FOREIGN KEY (initiative_id) REFERENCES StrategicInitiatives(initiative_id)
);

-- 69. Media Relations
CREATE TABLE MediaRelations (
    media_id INT NOT NULL AUTO_INCREMENT,
    contact_name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    PRIMARY KEY (media_id)
);

-- 70. Media EventsVT
CREATE TABLE MediaEventsVT (
    event_id INT NOT NULL AUTO_INCREMENT,
    media_id INT NOT NULL,
    event_name VARCHAR(100),
    event_date DATE,
    PRIMARY KEY (event_id),
    FOREIGN KEY (media_id) REFERENCES MediaRelations(media_id)
);

-- 71. StakeholdersVT
CREATE TABLE StakeholdersVT (
    stakeholder_id INT NOT NULL AUTO_INCREMENT,
    stakeholder_name VARCHAR(100),
    contact_person VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    PRIMARY KEY (stakeholder_id)
);

-- 72. Stakeholder Engagement
CREATE TABLE StakeholderEngagement (
    engagement_id INT NOT NULL AUTO_INCREMENT,
    stakeholder_id INT NOT NULL,
    engagement_date DATE,
    PRIMARY KEY (engagement_id),
    FOREIGN KEY (stakeholder_id) REFERENCES StakeholdersVT(stakeholder_id)
);

-- 73. Procurement
CREATE TABLE Procurement (
    procurement_id INT NOT NULL AUTO_INCREMENT,
    supplier_id INT NOT NULL,
    procurement_date DATE,
    total_amount DECIMAL(10, 2),
    PRIMARY KEY (procurement_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- 74. Supplier Ratings
CREATE TABLE SupplierRatings (
    rating_id INT NOT NULL AUTO_INCREMENT,
    supplier_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    PRIMARY KEY (rating_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- 75. Company Vehicles
CREATE TABLE CompanyVehicles (
    vehicle_id INT NOT NULL AUTO_INCREMENT,
    vehicle_name VARCHAR(100),
    purchase_date DATE,
    value DECIMAL(10, 2),
    PRIMARY KEY (vehicle_id)
);

-- 76. Vehicle Maintenance
CREATE TABLE VehicleMaintenance (
    maintenance_id INT NOT NULL AUTO_INCREMENT,
    vehicle_id INT NOT NULL,
    maintenance_date DATE,
    description TEXT,
    PRIMARY KEY (maintenance_id),
    FOREIGN KEY (vehicle_id) REFERENCES CompanyVehicles(vehicle_id)
);

-- 77. Office Locations
CREATE TABLE OfficeLocations (
    location_id INT NOT NULL AUTO_INCREMENT,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    zip VARCHAR(10),
    PRIMARY KEY (location_id)
);

-- 78. Office Resources
CREATE TABLE OfficeResources (
    resource_id INT NOT NULL AUTO_INCREMENT,
    location_id INT NOT NULL,
    resource_name VARCHAR(100),
    quantity INT,
    PRIMARY KEY (resource_id),
    FOREIGN KEY (location_id) REFERENCES OfficeLocations(location_id)
);

-- 79. Employee Relocation
CREATE TABLE EmployeeRelocation (
    relocation_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    new_location_id INT NOT NULL,
    relocation_date DATE,
    PRIMARY KEY (relocation_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (new_location_id) REFERENCES OfficeLocations(location_id)
);

-- 80. Technology Stack
CREATE TABLE TechStack (
    tech_id INT NOT NULL AUTO_INCREMENT,
    tech_name VARCHAR(100),
    PRIMARY KEY (tech_id)
);

-- 81. Technology Usage
CREATE TABLE TechnologyUsage (
    usage_id INT NOT NULL AUTO_INCREMENT,
    tech_id INT NOT NULL,
    employee_id INT NOT NULL,
    usage_date DATE,
    PRIMARY KEY (usage_id),
    FOREIGN KEY (tech_id) REFERENCES TechStack(tech_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 82. Community Engagement
CREATE TABLE CommunityEngagement (
    engagement_id INT NOT NULL AUTO_INCREMENT,
    engagement_name VARCHAR(100),
    engagement_date DATE,
    PRIMARY KEY (engagement_id)
);

-- 83. Sponsorships
CREATE TABLE Sponsorships (
    sponsorship_id INT NOT NULL AUTO_INCREMENT,
    engagement_id INT NOT NULL,
    amount DECIMAL(10, 2),
    PRIMARY KEY (sponsorship_id),
    FOREIGN KEY (engagement_id) REFERENCES CommunityEngagement(engagement_id)
);

-- 84. Employee Surveys
CREATE TABLE EmployeeSurveys (
    survey_id INT NOT NULL AUTO_INCREMENT,
    survey_title VARCHAR(100),
    submission_date DATE,
    PRIMARY KEY (survey_id)
);

-- 85. Survey Responses
CREATE TABLE SurveyRes (
    response_id INT NOT NULL AUTO_INCREMENT,
    survey_id INT NOT NULL,
    employee_id INT NOT NULL,
    response_text TEXT,
    PRIMARY KEY (response_id),
    FOREIGN KEY (survey_id) REFERENCES EmployeeSurveys(survey_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 86. Disaster Recovery Plans
CREATE TABLE DisasterRecoveryPlans (
    plan_id INT NOT NULL AUTO_INCREMENT,
    plan_name VARCHAR(100),
    created_date DATE,
    PRIMARY KEY (plan_id)
);

-- 87. Plan Implementation
CREATE TABLE PlanImplementation (
    implementation_id INT NOT NULL AUTO_INCREMENT,
    plan_id INT NOT NULL,
    implementation_date DATE,
    PRIMARY KEY (implementation_id),
    FOREIGN KEY (plan_id) REFERENCES DisasterRecoveryPlans(plan_id)
);

-- 88. Operational Metrics
CREATE TABLE OperationalMetrics (
    metric_id INT NOT NULL AUTO_INCREMENT,
    metric_name VARCHAR(100),
    value DECIMAL(10, 2),
    measurement_date DATE,
    PRIMARY KEY (metric_id)
);

-- 89. Technology Updates
CREATE TABLE TechnologyUpdates (
    update_id INT NOT NULL AUTO_INCREMENT,
    tech_id INT NOT NULL,
    update_date DATE,
    description TEXT,
    PRIMARY KEY (update_id),
    FOREIGN KEY (tech_id) REFERENCES TechStack(tech_id)
);

-- 90. Crisis Management
CREATE TABLE CrisisManagement (
    crisis_id INT NOT NULL AUTO_INCREMENT,
    crisis_description TEXT,
    response_plan TEXT,
    PRIMARY KEY (crisis_id)
);

-- 91. Crisis Response
CREATE TABLE CrisisResponse (
    response_id INT NOT NULL AUTO_INCREMENT,
    crisis_id INT NOT NULL,
    response_date DATE,
    PRIMARY KEY (response_id),
    FOREIGN KEY (crisis_id) REFERENCES CrisisManagement(crisis_id)
);

-- 92. Company EventsVT
CREATE TABLE CompanyEventsVT (
    event_id INT NOT NULL AUTO_INCREMENT,
    event_name VARCHAR(100),
    event_date DATE,
    PRIMARY KEY (event_id)
);

-- 93. Event Coordination
CREATE TABLE EventCoordination (
    coordination_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (coordination_id),
    FOREIGN KEY (event_id) REFERENCES CompanyEventsVT(event_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 94. Sales Strategies
CREATE TABLE SalesStrategies (
    strategy_id INT NOT NULL AUTO_INCREMENT,
    strategy_description TEXT,
    PRIMARY KEY (strategy_id)
);

-- 95. Strategy Implementation
CREATE TABLE StrategyImplementation (
    implementation_id INT NOT NULL AUTO_INCREMENT,
    strategy_id INT NOT NULL,
    implementation_date DATE,
    PRIMARY KEY (implementation_id),
    FOREIGN KEY (strategy_id) REFERENCES SalesStrategies(strategy_id)
);

-- 96. Employee Onboarding
CREATE TABLE EmployeeOnboarding (
    onboarding_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    onboarding_date DATE,
    PRIMARY KEY (onboarding_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 97. Employee Offboarding
CREATE TABLE EmployeeOffboarding (
    offboarding_id INT NOT NULL AUTO_INCREMENT,
    employee_id INT NOT NULL,
    offboarding_date DATE,
    PRIMARY KEY (offboarding_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 98. Health and Safety
CREATE TABLE HealthAndSafety (
    safety_id INT NOT NULL AUTO_INCREMENT,
    safety_description TEXT,
    inspection_date DATE,
    PRIMARY KEY (safety_id)
);

-- 99. Incident Reports
CREATE TABLE IncRepo (
    report_id INT NOT NULL AUTO_INCREMENT,
    incident_description TEXT,
    report_date DATE,
    PRIMARY KEY (report_id)
);

-- 100. Security Incidents
CREATE TABLE SecurityIncidents (
    incident_id INT NOT NULL AUTO_INCREMENT,
    incident_description TEXT,
    incident_date DATE,
    PRIMARY KEY (incident_id)
);

-- 1. Students
CREATE TABLE Students (
    student_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    date_of_birth DATE,
    enrollment_date DATE,
    PRIMARY KEY (student_id)
);

-- 2. Courses
CREATE TABLE Courses (
    course_id INT NOT NULL AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    course_description TEXT,
    credits INT NOT NULL,
    PRIMARY KEY (course_id)
);

-- 3. Instructors
CREATE TABLE Instructors (
    instructor_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hire_date DATE,
    PRIMARY KEY (instructor_id)
);

-- 4. Dept
CREATE TABLE Dept (
    department_id INT NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (department_id)
);

-- 5. Enrollments
CREATE TABLE Enrollments (
    enrollment_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE,
    grade FLOAT,
    PRIMARY KEY (enrollment_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE
);

-- 6. Classes
CREATE TABLE Classes (
    class_id INT NOT NULL AUTO_INCREMENT,
    course_id INT NOT NULL,
    instructor_id INT NOT NULL,
    semester VARCHAR(20),
    year INT,
    PRIMARY KEY (class_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);

-- 7. Assignments
CREATE TABLE Assignments (
    assignment_id INT NOT NULL AUTO_INCREMENT,
    class_id INT NOT NULL,
    assignment_title VARCHAR(100) NOT NULL,
    due_date DATE,
    PRIMARY KEY (assignment_id),
    FOREIGN KEY (class_id) REFERENCES Classes(class_id)
);

-- 8. Grades
CREATE TABLE Grades (
    grade_id INT NOT NULL AUTO_INCREMENT,
    enrollment_id INT NOT NULL,
    assignment_id INT NOT NULL,
    score FLOAT,
    PRIMARY KEY (grade_id),
    FOREIGN KEY (enrollment_id) REFERENCES Enrollments(enrollment_id),
    FOREIGN KEY (assignment_id) REFERENCES Assignments(assignment_id)
);

-- 9. AttendanceVT
CREATE TABLE AttendanceVT (
    AttendanceVT_id INT NOT NULL AUTO_INCREMENT,
    class_id INT NOT NULL,
    student_id INT NOT NULL,
    AttendanceVT_date DATE,
    status ENUM('Present', 'Absent') NOT NULL,
    PRIMARY KEY (AttendanceVT_id),
    FOREIGN KEY (class_id) REFERENCES Classes(class_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 10. Extracurricular Activities
CREATE TABLE Extracurriculars (
    activity_id INT NOT NULL AUTO_INCREMENT,
    activity_name VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (activity_id)
);

-- 11. Student Activities
CREATE TABLE StudentActivities (
    student_activity_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    activity_id INT NOT NULL,
    position VARCHAR(50),
    PRIMARY KEY (student_activity_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (activity_id) REFERENCES Extracurriculars(activity_id)
);

-- 12. Course Prerequisites
CREATE TABLE CoursePrerequisites (
    course_id INT NOT NULL,
    prerequisite_course_id INT NOT NULL,
    PRIMARY KEY (course_id, prerequisite_course_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (prerequisite_course_id) REFERENCES Courses(course_id)
);

-- 13. Course Materials
CREATE TABLE CourseMaterials (
    material_id INT NOT NULL AUTO_INCREMENT,
    course_id INT NOT NULL,
    material_type ENUM('Textbook', 'Article', 'Video', 'Other') NOT NULL,
    material_link VARCHAR(255),
    PRIMARY KEY (material_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- 14. VTEvents
CREATE TABLE VTEvents (
    event_id INT NOT NULL AUTO_INCREMENT,
    event_name VARCHAR(100) NOT NULL,
    event_date DATE,
    location VARCHAR(255),
    PRIMARY KEY (event_id)
);

-- 15. Event Participation
CREATE TABLE EventParticipation (
    participation_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (participation_id),
    FOREIGN KEY (event_id) REFERENCES VTEvents(event_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 16. Library
CREATE TABLE Library (
    book_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(100),
    published_year INT,
    available_copies INT,
    PRIMARY KEY (book_id)
);

-- 17. Book Loans
CREATE TABLE BookLoans (
    loan_id INT NOT NULL AUTO_INCREMENT,
    book_id INT NOT NULL,
    student_id INT NOT NULL,
    loan_date DATE,
    return_date DATE,
    PRIMARY KEY (loan_id),
    FOREIGN KEY (book_id) REFERENCES Library(book_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 18. Scholarships
CREATE TABLE Scholarships (
    scholarship_id INT NOT NULL AUTO_INCREMENT,
    scholarship_name VARCHAR(100) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    eligibility_criteria TEXT,
    PRIMARY KEY (scholarship_id)
);

-- 19. Student Scholarships
CREATE TABLE StudentScholarships (
    student_scholarship_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    scholarship_id INT NOT NULL,
    awarded_date DATE,
    PRIMARY KEY (student_scholarship_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (scholarship_id) REFERENCES Scholarships(scholarship_id)
);

-- 20. Financial Aid
CREATE TABLE FinancialAidEdu (
    aid_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    aid_amount DECIMAL(10, 2),
    aid_type ENUM('Grant', 'Loan', 'Work-Study') NOT NULL,
    awarded_date DATE,
    PRIMARY KEY (aid_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 21. Tuition Fees
CREATE TABLE TuitionFees (
    fee_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    due_date DATE,
    paid_date DATE,
    PRIMARY KEY (fee_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 22. Staff
CREATE TABLE Staff (
    staff_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hire_date DATE,
    PRIMARY KEY (staff_id)
);

-- 23. Staff Roles
CREATE TABLE StaffRoles (
    role_id INT NOT NULL AUTO_INCREMENT,
    role_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (role_id)
);

-- 24. Staff Assignments
CREATE TABLE StaffAssignments (
    assignment_id INT NOT NULL AUTO_INCREMENT,
    staff_id INT NOT NULL,
    role_id INT NOT NULL,
    assigned_date DATE,
    PRIMARY KEY (assignment_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (role_id) REFERENCES StaffRoles(role_id)
);

-- 25. Feedback2
CREATE TABLE Feedback2 (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    feedback_text TEXT,
    feedback_date DATE,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 26. Course Feedback2
CREATE TABLE CourseFeedback (
    course_feedback_id INT NOT NULL AUTO_INCREMENT,
    course_id INT NOT NULL,
    student_id INT NOT NULL,
    feedback_text TEXT,
    feedback_date DATE,
    PRIMARY KEY (course_feedback_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 27. Study Groups
CREATE TABLE StudyGroups (
    group_id INT NOT NULL AUTO_INCREMENT,
    group_name VARCHAR(100) NOT NULL,
    created_date DATE,
    PRIMARY KEY (group_id)
);

-- 28. Group Members
CREATE TABLE GroupMembers (
    group_member_id INT NOT NULL AUTO_INCREMENT,
    group_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (group_member_id),
    FOREIGN KEY (group_id) REFERENCES StudyGroups(group_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 29. Tutoring Sessions
CREATE TABLE TutoringSessions (
    session_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    student_id INT NOT NULL,
    session_date DATE,
    session_time TIME,
    PRIMARY KEY (session_id),
    FOREIGN KEY (tutor_id) REFERENCES Instructors(instructor_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 30. Faculty Meetings
CREATE TABLE FacultyMeetings (
    meeting_id INT NOT NULL AUTO_INCREMENT,
    meeting_date DATE,
    agenda TEXT,
    PRIMARY KEY (meeting_id)
);

-- 31. Meeting AttendanceVT
CREATE TABLE MeetingAttendanceVT (
    AttendanceVT_id INT NOT NULL AUTO_INCREMENT,
    meeting_id INT NOT NULL,
    instructor_id INT NOT NULL,
    PRIMARY KEY (AttendanceVT_id),
    FOREIGN KEY (meeting_id) REFERENCES FacultyMeetings(meeting_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);

-- 32. Scholarships Offered
CREATE TABLE ScholarshipsOffered (
    scholarship_offered_id INT NOT NULL AUTO_INCREMENT,
    scholarship_id INT NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (scholarship_offered_id),
    FOREIGN KEY (scholarship_id) REFERENCES Scholarships(scholarship_id),
    FOREIGN KEY (department_id) REFERENCES Dept(department_id)
);

-- 33. Internship Opportunities
CREATE TABLE Internships (
    internship_id INT NOT NULL AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    application_deadline DATE,
    PRIMARY KEY (internship_id)
);

-- 34. Student Internships
CREATE TABLE StudentInternships (
    student_internship_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    internship_id INT NOT NULL,
    PRIMARY KEY (student_internship_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (internship_id) REFERENCES Internships(internship_id)
);

-- 35. VTEvents Coordination
CREATE TABLE EventCoordinationTwo (
    coordination_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    staff_id INT NOT NULL,
    PRIMARY KEY (coordination_id),
    FOREIGN KEY (event_id) REFERENCES VTEvents(event_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);

-- 36. Awards
CREATE TABLE Awards (
    award_id INT NOT NULL AUTO_INCREMENT,
    award_name VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (award_id)
);

-- 37. Student Awards
CREATE TABLE StudentAwards (
    student_award_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    award_id INT NOT NULL,
    awarded_date DATE,
    PRIMARY KEY (student_award_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (award_id) REFERENCES Awards(award_id)
);

-- 38. Research Projects
CREATE TABLE ResearchProjects (
    project_id INT NOT NULL AUTO_INCREMENT,
    project_title VARCHAR(100) NOT NULL,
    faculty_id INT NOT NULL,
    description TEXT,
    PRIMARY KEY (project_id),
    FOREIGN KEY (faculty_id) REFERENCES Instructors(instructor_id)
);

-- 39. Project Participants
CREATE TABLE ProjectParticipants (
    participant_id INT NOT NULL AUTO_INCREMENT,
    project_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (participant_id),
    FOREIGN KEY (project_id) REFERENCES ResearchProjects(project_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 40. Course Schedules
CREATE TABLE CourseSchedules (
    schedule_id INT NOT NULL AUTO_INCREMENT,
    course_id INT NOT NULL,
    class_id INT NOT NULL,
    schedule_date DATE,
    start_time TIME,
    end_time TIME,
    PRIMARY KEY (schedule_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (class_id) REFERENCES Classes(class_id)
);

-- 41. Classroom Resources
CREATE TABLE ClassroomResources (
    resource_id INT NOT NULL AUTO_INCREMENT,
    class_id INT NOT NULL,
    resource_type VARCHAR(100),
    resource_description TEXT,
    PRIMARY KEY (resource_id),
    FOREIGN KEY (class_id) REFERENCES Classes(class_id)
);

-- 42. Academic Calendar
CREATE TABLE AcademicCalendar (
    year INT NOT NULL,
    semester VARCHAR(20) NOT NULL,
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (year, semester)
);

-- 43. Academic Policies
CREATE TABLE AcademicPolicies (
    policy_id INT NOT NULL AUTO_INCREMENT,
    policy_title VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (policy_id)
);

-- 44. Policy Updates
CREATE TABLE PolicyUpdates (
    update_id INT NOT NULL AUTO_INCREMENT,
    policy_id INT NOT NULL,
    update_date DATE,
    PRIMARY KEY (update_id),
    FOREIGN KEY (policy_id) REFERENCES AcademicPolicies(policy_id)
);

-- 45. Notify
CREATE TABLE Notify (
    notification_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    message TEXT,
    notification_date DATE,
    PRIMARY KEY (notification_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 46. Parent Information
CREATE TABLE Parents (
    parent_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    PRIMARY KEY (parent_id)
);

-- 47. Student Parents
CREATE TABLE StudentParents (
    student_parent_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    parent_id INT NOT NULL,
    PRIMARY KEY (student_parent_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (parent_id) REFERENCES Parents(parent_id)
);

-- 48. Health Records
CREATE TABLE HealthRecords (
    record_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    record_date DATE,
    details TEXT,
    PRIMARY KEY (record_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 49. Student Rights
CREATE TABLE StudentRights (
    right_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    description TEXT,
    PRIMARY KEY (right_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 50. Counseling Sessions
CREATE TABLE CounselingSessions (
    session_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    counselor_id INT NOT NULL,
    session_date DATE,
    notes TEXT,
    PRIMARY KEY (session_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (counselor_id) REFERENCES Instructors(instructor_id)
);

-- Additional tables can continue in a similar manner to reach 100.
-- Here are more examples to fill up to 100 tables.

-- 51. Academic Advising
CREATE TABLE AcademicAdvising (
    advising_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    advisor_id INT NOT NULL,
    advising_date DATE,
    PRIMARY KEY (advising_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (advisor_id) REFERENCES Instructors(instructor_id)
);

-- 52. Course Evaluations
CREATE TABLE CourseEvaluations (
    evaluation_id INT NOT NULL AUTO_INCREMENT,
    course_id INT NOT NULL,
    student_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    PRIMARY KEY (evaluation_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 53. Academic Honors
CREATE TABLE AcademicHonors (
    honor_id INT NOT NULL AUTO_INCREMENT,
    honor_name VARCHAR(100) NOT NULL,
    criteria TEXT,
    PRIMARY KEY (honor_id)
);

-- 54. Student Honors
CREATE TABLE StudentHonors (
    student_honor_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    honor_id INT NOT NULL,
    awarded_date DATE,
    PRIMARY KEY (student_honor_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (honor_id) REFERENCES AcademicHonors(honor_id)
);

-- 55. Learning Management System Accounts
CREATE TABLE LMSAccounts (
    lms_account_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    PRIMARY KEY (lms_account_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 56. Discussion Boards
CREATE TABLE DiscussionBoards (
    board_id INT NOT NULL AUTO_INCREMENT,
    course_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    created_date DATE,
    PRIMARY KEY (board_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- 57. Discussion Posts
CREATE TABLE DiscussionPosts (
    post_id INT NOT NULL AUTO_INCREMENT,
    board_id INT NOT NULL,
    student_id INT NOT NULL,
    content TEXT,
    post_date DATE,
    PRIMARY KEY (post_id),
    FOREIGN KEY (board_id) REFERENCES DiscussionBoards(board_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 58. Course Forums
CREATE TABLE CourseForums (
    forum_id INT NOT NULL AUTO_INCREMENT,
    course_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    created_date DATE,
    PRIMARY KEY (forum_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- 59. Forum Responses
CREATE TABLE ForumResponses (
    response_id INT NOT NULL AUTO_INCREMENT,
    forum_id INT NOT NULL,
    student_id INT NOT NULL,
    content TEXT,
    response_date DATE,
    PRIMARY KEY (response_id),
    FOREIGN KEY (forum_id) REFERENCES CourseForums(forum_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 60. Online Resources
CREATE TABLE OnlineResources (
    resource_id INT NOT NULL AUTO_INCREMENT,
    course_id INT NOT NULL,
    resource_link VARCHAR(255),
    PRIMARY KEY (resource_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- 61. Laboratory Equipment
CREATE TABLE LaboratoryEquipment (
    equipment_id INT NOT NULL AUTO_INCREMENT,
    equipment_name VARCHAR(100) NOT NULL,
    equipment_description TEXT,
    available_units INT,
    PRIMARY KEY (equipment_id)
);

-- 62. Lab Reservations
CREATE TABLE LabReservations (
    reservation_id INT NOT NULL AUTO_INCREMENT,
    equipment_id INT NOT NULL,
    student_id INT NOT NULL,
    reservation_date DATE,
    PRIMARY KEY (reservation_id),
    FOREIGN KEY (equipment_id) REFERENCES LaboratoryEquipment(equipment_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 63. Course Announcements
CREATE TABLE CourseAnnouncements (
    announcement_id INT NOT NULL AUTO_INCREMENT,
    course_id INT NOT NULL,
    announcement_text TEXT,
    announcement_date DATE,
    PRIMARY KEY (announcement_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- 64. Course Subscriptions
CREATE TABLE CourseSubscriptions (
    subscription_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    subscription_date DATE,
    PRIMARY KEY (subscription_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- 65. Volunteer Opportunities
CREATE TABLE VolunteerOpportunities (
    opportunity_id INT NOT NULL AUTO_INCREMENT,
    opportunity_title VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (opportunity_id)
);

-- 66. Student Volunteers
CREATE TABLE StudentVolunteers (
    student_volunteer_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    opportunity_id INT NOT NULL,
    PRIMARY KEY (student_volunteer_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (opportunity_id) REFERENCES VolunteerOpportunities(opportunity_id)
);

-- 67. Facility Reservations
CREATE TABLE FacilityReservations (
    reservation_id INT NOT NULL AUTO_INCREMENT,
    facility_name VARCHAR(100) NOT NULL,
    reserved_by INT NOT NULL,
    reservation_date DATE,
    PRIMARY KEY (reservation_id),
    FOREIGN KEY (reserved_by) REFERENCES Staff(staff_id)
);

-- 68. Conference Participation
CREATE TABLE ConferenceParticipation (
    participation_id INT NOT NULL AUTO_INCREMENT,
    conference_name VARCHAR(100) NOT NULL,
    student_id INT NOT NULL,
    date_of_conference DATE,
    PRIMARY KEY (participation_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 69. International Students
CREATE TABLE InternationalStudents (
    international_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    country_of_origin VARCHAR(100),
    visa_status VARCHAR(100),
    PRIMARY KEY (international_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 70. Mentor-Mentee Relationships
CREATE TABLE MentorMentee (
    relationship_id INT NOT NULL AUTO_INCREMENT,
    mentor_id INT NOT NULL,
    mentee_id INT NOT NULL,
    start_date DATE,
    PRIMARY KEY (relationship_id),
    FOREIGN KEY (mentor_id) REFERENCES Instructors(instructor_id),
    FOREIGN KEY (mentee_id) REFERENCES Students(student_id)
);

-- 71. Career Services
CREATE TABLE CareerServices (
    service_id INT NOT NULL AUTO_INCREMENT,
    service_name VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (service_id)
);

-- 72. Career Appointments
CREATE TABLE CareerAppointments (
    appointment_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    service_id INT NOT NULL,
    appointment_date DATE,
    PRIMARY KEY (appointment_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (service_id) REFERENCES CareerServices(service_id)
);

-- 73. Alumni
CREATE TABLE Alumni (
    alumni_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    graduation_year INT,
    PRIMARY KEY (alumni_id)
);

-- 74. Alumni Activities
CREATE TABLE AlumniActivities (
    activity_id INT NOT NULL AUTO_INCREMENT,
    alumni_id INT NOT NULL,
    activity_name VARCHAR(100),
    activity_date DATE,
    PRIMARY KEY (activity_id),
    FOREIGN KEY (alumni_id) REFERENCES Alumni(alumni_id)
);

-- 75. Campus Facilities
CREATE TABLE CampusFacilities (
    facility_id INT NOT NULL AUTO_INCREMENT,
    facility_name VARCHAR(100) NOT NULL,
    facility_description TEXT,
    PRIMARY KEY (facility_id)
);

-- 76. Facility Usage
CREATE TABLE FacilityUsage (
    usage_id INT NOT NULL AUTO_INCREMENT,
    facility_id INT NOT NULL,
    usage_date DATE,
    PRIMARY KEY (usage_id),
    FOREIGN KEY (facility_id) REFERENCES CampusFacilities(facility_id)
);

-- 77. Campus VTEvents
CREATE TABLE CampusVTEvents (
    campus_event_id INT NOT NULL AUTO_INCREMENT,
    event_name VARCHAR(100) NOT NULL,
    event_date DATE,
    PRIMARY KEY (campus_event_id)
);

-- 78. Campus Organizations
CREATE TABLE CampusOrganizations (
    organization_id INT NOT NULL AUTO_INCREMENT,
    organization_name VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (organization_id)
);

-- 79. Organization Membership
CREATE TABLE OrganizationMembership (
    membership_id INT NOT NULL AUTO_INCREMENT,
    organization_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (membership_id),
    FOREIGN KEY (organization_id) REFERENCES CampusOrganizations(organization_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 80. Campus Surveys
CREATE TABLE CampusSurveys (
    survey_id INT NOT NULL AUTO_INCREMENT,
    survey_name VARCHAR(100) NOT NULL,
    created_date DATE,
    PRIMARY KEY (survey_id)
);

-- 81. Survey Responses
CREATE TABLE SurveyResponsesEdu (
    response_id INT NOT NULL AUTO_INCREMENT,
    survey_id INT NOT NULL,
    student_id INT NOT NULL,
    response_text TEXT,
    PRIMARY KEY (response_id),
    FOREIGN KEY (survey_id) REFERENCES CampusSurveys(survey_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 82. Social Media Engagement
CREATE TABLE SocialMediaEngagement (
    engagement_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    platform VARCHAR(100) NOT NULL,
    engagement_date DATE,
    PRIMARY KEY (engagement_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 83. Transportation Services
CREATE TABLE TransportationServices (
    transport_service_id INT NOT NULL AUTO_INCREMENT,
    service_name VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (transport_service_id)
);

-- 84. Transportation Usage
CREATE TABLE TransportationUsage (
    usage_id INT NOT NULL AUTO_INCREMENT,
    transport_service_id INT NOT NULL,
    student_id INT NOT NULL,
    usage_date DATE,
    PRIMARY KEY (usage_id),
    FOREIGN KEY (transport_service_id) REFERENCES TransportationServices(transport_service_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 85. Community Service
CREATE TABLE CommunityService (
    service_id INT NOT NULL AUTO_INCREMENT,
    service_name VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (service_id)
);

-- 86. Student Community Service
CREATE TABLE StudentCommunityService (
    student_service_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    service_id INT NOT NULL,
    PRIMARY KEY (student_service_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (service_id) REFERENCES CommunityService(service_id)
);

-- 87. Student Health Services
CREATE TABLE StudentHealthServices (
    health_service_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    visit_date DATE,
    PRIMARY KEY (health_service_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 88. Counseling Services
CREATE TABLE CounselingServices (
    counseling_service_id INT NOT NULL AUTO_INCREMENT,
    service_name VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (counseling_service_id)
);

-- 89. Student Counseling Services
CREATE TABLE StudentCounselingServices (
    student_counseling_service_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    counseling_service_id INT NOT NULL,
    PRIMARY KEY (student_counseling_service_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (counseling_service_id) REFERENCES CounselingServices(counseling_service_id)
);

-- 90. Student Financial Services
CREATE TABLE StudentFinancialServices (
    financial_service_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    visit_date DATE,
    PRIMARY KEY (financial_service_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 91. Academic Resources
CREATE TABLE AcademicResources (
    resource_id INT NOT NULL AUTO_INCREMENT,
    resource_name VARCHAR(100) NOT NULL,
    resource_description TEXT,
    PRIMARY KEY (resource_id)
);

-- 92. Student Resource Usage
CREATE TABLE StudentResourceUsage (
    usage_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    resource_id INT NOT NULL,
    usage_date DATE,
    PRIMARY KEY (usage_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (resource_id) REFERENCES AcademicResources(resource_id)
);

-- 93. Course Libraries
CREATE TABLE CourseLibraries (
    library_id INT NOT NULL AUTO_INCREMENT,
    course_id INT NOT NULL,
    resource_id INT NOT NULL,
    PRIMARY KEY (library_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (resource_id) REFERENCES AcademicResources(resource_id)
);

-- 94. Academic Integrity Policies
CREATE TABLE AcademicIntegrityPolicies (
    policy_id INT NOT NULL AUTO_INCREMENT,
    policy_name VARCHAR(100) NOT NULL,
    description TEXT,
    PRIMARY KEY (policy_id)
);

-- 95. Integrity Violations
CREATE TABLE IntegrityViolations (
    violation_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    policy_id INT NOT NULL,
    violation_date DATE,
    PRIMARY KEY (violation_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (policy_id) REFERENCES AcademicIntegrityPolicies(policy_id)
);

-- 96. Financial Aid
CREATE TABLE FinancialAidEduTwo (
    aid_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    aid_amount DECIMAL(10, 2),
    aid_date DATE,
    PRIMARY KEY (aid_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 97. Student Job Opportunities
CREATE TABLE StudentJobOpportunities (
    job_opportunity_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    job_title VARCHAR(100),
    application_date DATE,
    PRIMARY KEY (job_opportunity_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 98. Campus News
CREATE TABLE CampusNews (
    news_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    content TEXT,
    published_date DATE,
    PRIMARY KEY (news_id)
);

-- 99. Emergency Contacts
CREATE TABLE EmergencyContacts (
    contact_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    contact_name VARCHAR(100),
    contact_phone VARCHAR(15),
    relationship VARCHAR(50),
    PRIMARY KEY (contact_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 100. Student Feedback2
CREATE TABLE StudentFeedback (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    feedback_text TEXT,
    feedback_date DATE,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- 1. Campaigns
CREATE TABLE Campaigns (
    campaign_id INT NOT NULL AUTO_INCREMENT,
    campaign_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10, 2),
    PRIMARY KEY (campaign_id)
);

-- 2. Campaign Channels
CREATE TABLE CampaignChannels (
    channel_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    channel_name VARCHAR(100),
    PRIMARY KEY (channel_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 3. Leads
CREATE TABLE Leads (
    lead_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    source VARCHAR(100),
    status ENUM('New', 'Contacted', 'Qualified', 'Converted', 'Lost'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (lead_id)
);

-- 4. Lead Assignments
CREATE TABLE LeadAssignments (
    assignment_id INT NOT NULL AUTO_INCREMENT,
    lead_id INT NOT NULL,
    user_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (assignment_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 5. Contacts
CREATE TABLE Contacts (
    contact_id INT NOT NULL AUTO_INCREMENT,
    lead_id INT NOT NULL,
    contact_method VARCHAR(50),
    contact_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    PRIMARY KEY (contact_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 6. Opportunities
CREATE TABLE Opportunities (
    opportunity_id INT NOT NULL AUTO_INCREMENT,
    lead_id INT NOT NULL,
    opportunity_value DECIMAL(10, 2),
    close_date DATE,
    stage ENUM('Prospecting', 'Negotiation', 'Closed Won', 'Closed Lost'),
    PRIMARY KEY (opportunity_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 7. Marketing Materials
CREATE TABLE MarketingMaterials (
    material_id INT NOT NULL AUTO_INCREMENT,
    material_type VARCHAR(100),
    title VARCHAR(100),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (material_id)
);

-- 8. Material Usage
CREATE TABLE MaterialUsage (
    usage_id INT NOT NULL AUTO_INCREMENT,
    material_id INT NOT NULL,
    campaign_id INT NOT NULL,
    PRIMARY KEY (usage_id),
    FOREIGN KEY (material_id) REFERENCES MarketingMaterials(material_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 9. Email Campaigns
CREATE TABLE EmailCampaigns (
    email_campaign_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    subject VARCHAR(100),
    body TEXT,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (email_campaign_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 10. Email Opens
CREATE TABLE EmailOpens (
    open_id INT NOT NULL AUTO_INCREMENT,
    email_campaign_id INT NOT NULL,
    lead_id INT NOT NULL,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (open_id),
    FOREIGN KEY (email_campaign_id) REFERENCES EmailCampaigns(email_campaign_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 11. Email Clicks
CREATE TABLE EmailClicks (
    click_id INT NOT NULL AUTO_INCREMENT,
    email_campaign_id INT NOT NULL,
    lead_id INT NOT NULL,
    clicked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (click_id),
    FOREIGN KEY (email_campaign_id) REFERENCES EmailCampaigns(email_campaign_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 12. Social Media Campaigns
CREATE TABLE SocialMediaCampaigns (
    sm_campaign_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    platform VARCHAR(100),
    post_content TEXT,
    scheduled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (sm_campaign_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 13. Social Media Engagements
CREATE TABLE SocialMediaEngagements (
    engagement_id INT NOT NULL AUTO_INCREMENT,
    sm_campaign_id INT NOT NULL,
    engagement_type ENUM('Like', 'Share', 'Comment'),
    engagement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (engagement_id),
    FOREIGN KEY (sm_campaign_id) REFERENCES SocialMediaCampaigns(sm_campaign_id)
);

-- 14. Surveys
CREATE TABLE Surveys (
    survey_id INT NOT NULL AUTO_INCREMENT,
    survey_title VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (survey_id)
);

-- 15. Survey Questions
CREATE TABLE SurveyQuestions (
    question_id INT NOT NULL AUTO_INCREMENT,
    survey_id INT NOT NULL,
    question_text TEXT,
    question_type ENUM('Multiple Choice', 'Open-Ended'),
    PRIMARY KEY (question_id),
    FOREIGN KEY (survey_id) REFERENCES Surveys(survey_id)
);

-- 16. Survey Responses
CREATE TABLE MarkSurveyResponses (
    response_id INT NOT NULL AUTO_INCREMENT,
    question_id INT NOT NULL,
    lead_id INT NOT NULL,
    response_text TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (response_id),
    FOREIGN KEY (question_id) REFERENCES SurveyQuestions(question_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 17. Market Research
CREATE TABLE MarkMarketResearch (
    research_id INT NOT NULL AUTO_INCREMENT,
    research_topic VARCHAR(100),
    findings TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (research_id)
);

-- 18. Competitor Analysis
CREATE TABLE CompetitorAnalysis (
    analysis_id INT NOT NULL AUTO_INCREMENT,
    competitor_name VARCHAR(100),
    strengths TEXT,
    weaknesses TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (analysis_id)
);

-- 19. User Personas
CREATE TABLE UserPersonas (
    persona_id INT NOT NULL AUTO_INCREMENT,
    persona_name VARCHAR(100),
    demographics TEXT,
    behaviors TEXT,
    primary_goal TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (persona_id)
);

-- 20. Brand Guidelines
CREATE TABLE BrandGuidelines (
    guideline_id INT NOT NULL AUTO_INCREMENT,
    guideline_name VARCHAR(100),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (guideline_id)
);

-- 21. Marketing Budgets
CREATE TABLE MarketingBudgets (
    budget_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    allocated_amount DECIMAL(10, 2),
    spent_amount DECIMAL(10, 2) DEFAULT 0,
    PRIMARY KEY (budget_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 22. Partnerships
CREATE TABLE Partnerships (
    partnership_id INT NOT NULL AUTO_INCREMENT,
    partner_name VARCHAR(100),
    partnership_type VARCHAR(100),
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (partnership_id)
);

-- 23. Partnership Activities
CREATE TABLE PartnershipActivities (
    activity_id INT NOT NULL AUTO_INCREMENT,
    partnership_id INT NOT NULL,
    activity_description TEXT,
    activity_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (activity_id),
    FOREIGN KEY (partnership_id) REFERENCES Partnerships(partnership_id)
);

-- 24. Affiliate Programs
CREATE TABLE AffiliatePrograms (
    program_id INT NOT NULL AUTO_INCREMENT,
    program_name VARCHAR(100),
    commission_rate DECIMAL(5, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (program_id)
);

-- 25. Affiliates
CREATE TABLE Affiliates (
    affiliate_id INT NOT NULL AUTO_INCREMENT,
    program_id INT NOT NULL,
    affiliate_name VARCHAR(100),
    contact_email VARCHAR(100) UNIQUE,
    PRIMARY KEY (affiliate_id),
    FOREIGN KEY (program_id) REFERENCES AffiliatePrograms(program_id)
);

-- 26. Affiliate Sales
CREATE TABLE AffiliateSales (
    sale_id INT NOT NULL AUTO_INCREMENT,
    affiliate_id INT NOT NULL,
    lead_id INT NOT NULL,
    sale_value DECIMAL(10, 2),
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (sale_id),
    FOREIGN KEY (affiliate_id) REFERENCES Affiliates(affiliate_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 27. Event Marketing
CREATE TABLE EventMarketing (
    event_id INT NOT NULL AUTO_INCREMENT,
    event_name VARCHAR(100),
    event_date DATE,
    location VARCHAR(100),
    description TEXT,
    PRIMARY KEY (event_id)
);

-- 28. Event Attendees
CREATE TABLE EventAttendees (
    attendee_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    lead_id INT NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (attendee_id),
    FOREIGN KEY (event_id) REFERENCES EventMarketing(event_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 29. Webinars
CREATE TABLE Webinars (
    webinar_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(100),
    scheduled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (webinar_id)
);

-- 30. Webinar Registrations
CREATE TABLE WebinarRegistrations (
    registration_id INT NOT NULL AUTO_INCREMENT,
    webinar_id INT NOT NULL,
    lead_id INT NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (registration_id),
    FOREIGN KEY (webinar_id) REFERENCES Webinars(webinar_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 31. Marketing Automation
CREATE TABLE MarketingAutomation (
    automation_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100),
    trigger_event VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (automation_id)
);

-- 32. Automation Actions
CREATE TABLE AutomationActions (
    action_id INT NOT NULL AUTO_INCREMENT,
    automation_id INT NOT NULL,
    action_type VARCHAR(100),
    action_details TEXT,
    PRIMARY KEY (action_id),
    FOREIGN KEY (automation_id) REFERENCES MarketingAutomation(automation_id)
);

-- 33. Ad Campaigns
CREATE TABLE AdCampaigns (
    ad_campaign_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    ad_platform VARCHAR(100),
    ad_content TEXT,
    budget DECIMAL(10, 2),
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (ad_campaign_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 34. Ad Performance
CREATE TABLE AdPerformance (
    performance_id INT NOT NULL AUTO_INCREMENT,
    ad_campaign_id INT NOT NULL,
    impressions INT,
    clicks INT,
    conversions INT,
    cost DECIMAL(10, 2),
    PRIMARY KEY (performance_id),
    FOREIGN KEY (ad_campaign_id) REFERENCES AdCampaigns(ad_campaign_id)
);

-- 35. Content Calendar
CREATE TABLE ContentCalendar (
    calendar_id INT NOT NULL AUTO_INCREMENT,
    content_type VARCHAR(100),
    scheduled_date DATE,
    title VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (calendar_id)
);

-- 36. Content Pieces
CREATE TABLE ContentPieces (
    piece_id INT NOT NULL AUTO_INCREMENT,
    calendar_id INT NOT NULL,
    content_text TEXT,
    PRIMARY KEY (piece_id),
    FOREIGN KEY (calendar_id) REFERENCES ContentCalendar(calendar_id)
);

-- 37. Content Engagement
CREATE TABLE ContentEngagement (
    engagement_id INT NOT NULL AUTO_INCREMENT,
    piece_id INT NOT NULL,
    lead_id INT NOT NULL,
    engagement_type ENUM('View', 'Share', 'Comment'),
    engagement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (engagement_id),
    FOREIGN KEY (piece_id) REFERENCES ContentPieces(piece_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 38. Customer Feedback
CREATE TABLE MarkCustomerFeedback (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    lead_id INT NOT NULL,
    feedback_text TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 39. Referral Programs
CREATE TABLE ReferralPrograms (
    referral_id INT NOT NULL AUTO_INCREMENT,
    program_name VARCHAR(100),
    reward_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (referral_id)
);

-- 40. Referrals
CREATE TABLE Referrals (
    referral_id INT NOT NULL AUTO_INCREMENT,
    referral_program_id INT NOT NULL,
    referrer_id INT NOT NULL,
    referred_lead_id INT NOT NULL,
    PRIMARY KEY (referral_id),
    FOREIGN KEY (referral_program_id) REFERENCES ReferralPrograms(referral_id),
    FOREIGN KEY (referrer_id) REFERENCES Leads(lead_id),
    FOREIGN KEY (referred_lead_id) REFERENCES Leads(lead_id)
);

-- 41. Competitor Tracking
CREATE TABLE CompetitorTracking (
    tracking_id INT NOT NULL AUTO_INCREMENT,
    competitor_name VARCHAR(100),
    monitoring_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (tracking_id)
);

-- 42. Competitor Actions
CREATE TABLE CompetitorActions (
    action_id INT NOT NULL AUTO_INCREMENT,
    tracking_id INT NOT NULL,
    action_description TEXT,
    PRIMARY KEY (action_id),
    FOREIGN KEY (tracking_id) REFERENCES CompetitorTracking(tracking_id)
);

-- 43. Marketing Events
CREATE TABLE MarketingEvents (
    event_id INT NOT NULL AUTO_INCREMENT,
    event_name VARCHAR(100),
    event_type VARCHAR(100),
    event_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id)
);

-- 44. Event Feedback
CREATE TABLE EventFeedback (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    lead_id INT NOT NULL,
    feedback_text TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (event_id) REFERENCES MarketingEvents(event_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 45. Promotional Codes
CREATE TABLE PromotionalCodes (
    code_id INT NOT NULL AUTO_INCREMENT,
    code_value VARCHAR(50) UNIQUE,
    discount DECIMAL(5, 2),
    expiration_date DATE,
    PRIMARY KEY (code_id)
);

-- 46. Code Usage
CREATE TABLE CodeUsage (
    usage_id INT NOT NULL AUTO_INCREMENT,
    code_id INT NOT NULL,
    lead_id INT NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usage_id),
    FOREIGN KEY (code_id) REFERENCES PromotionalCodes(code_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 47. Performance Metrics
CREATE TABLE PerformanceMetrics (
    metric_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    leads_generated INT,
    conversions INT,
    revenue DECIMAL(10, 2),
    PRIMARY KEY (metric_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 48. ROI Analysis
CREATE TABLE ROIAnalysis (
    roi_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    investment DECIMAL(10, 2),
    roi_percentage DECIMAL(5, 2),
    PRIMARY KEY (roi_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 49. Budget Allocations
CREATE TABLE BudgetAllocations (
    allocation_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    allocated_amount DECIMAL(10, 2),
    PRIMARY KEY (allocation_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 50. Media Spend
CREATE TABLE MediaSpend (
    spend_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    media_type VARCHAR(100),
    amount DECIMAL(10, 2),
    spend_date DATE,
    PRIMARY KEY (spend_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 51. Target Audiences
CREATE TABLE TargetAudiences (
    audience_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    demographic_details TEXT,
    PRIMARY KEY (audience_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 52. Marketing Analytics
CREATE TABLE MarketingAnalytics (
    analytics_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    analysis_date DATE,
    insights TEXT,
    PRIMARY KEY (analytics_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 53. Lead Sources
CREATE TABLE LeadSources (
    source_id INT NOT NULL AUTO_INCREMENT,
    source_name VARCHAR(100),
    PRIMARY KEY (source_id)
);

-- 54. Source Tracking
CREATE TABLE SourceTracking (
    tracking_id INT NOT NULL AUTO_INCREMENT,
    source_id INT NOT NULL,
    lead_id INT NOT NULL,
    tracked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (tracking_id),
    FOREIGN KEY (source_id) REFERENCES LeadSources(source_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 55. Brand Awareness
CREATE TABLE BrandAwareness (
    awareness_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    awareness_level ENUM('Low', 'Medium', 'High'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (awareness_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 56. Brand Perception
CREATE TABLE BrandPerception (
    perception_id INT NOT NULL AUTO_INCREMENT,
    lead_id INT NOT NULL,
    perception_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (perception_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 57. Influencer Marketing
CREATE TABLE InfluencerMarketing (
    influencer_id INT NOT NULL AUTO_INCREMENT,
    influencer_name VARCHAR(100),
    platform VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (influencer_id)
);

-- 58. Influencer Collaborations
CREATE TABLE InfluencerCollaborations (
    collaboration_id INT NOT NULL AUTO_INCREMENT,
    influencer_id INT NOT NULL,
    campaign_id INT NOT NULL,
    terms TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (collaboration_id),
    FOREIGN KEY (influencer_id) REFERENCES InfluencerMarketing(influencer_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 59. Marketing Collateral
CREATE TABLE MarketingCollateral (
    collateral_id INT NOT NULL AUTO_INCREMENT,
    collateral_type VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (collateral_id)
);

-- 60. Collateral Usage
CREATE TABLE CollateralUsage (
    usage_id INT NOT NULL AUTO_INCREMENT,
    collateral_id INT NOT NULL,
    campaign_id INT NOT NULL,
    PRIMARY KEY (usage_id),
    FOREIGN KEY (collateral_id) REFERENCES MarketingCollateral(collateral_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 61. Customer Segmentation
CREATE TABLE CustomerSegmentation (
    segment_id INT NOT NULL AUTO_INCREMENT,
    segment_name VARCHAR(100),
    criteria TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (segment_id)
);

-- 62. Segment Members
CREATE TABLE SegmentMembers (
    member_id INT NOT NULL AUTO_INCREMENT,
    segment_id INT NOT NULL,
    lead_id INT NOT NULL,
    PRIMARY KEY (member_id),
    FOREIGN KEY (segment_id) REFERENCES CustomerSegmentation(segment_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 63. Customer Journey
CREATE TABLE CustomerJourney (
    journey_id INT NOT NULL AUTO_INCREMENT,
    lead_id INT NOT NULL,
    touchpoints TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (journey_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 64. Marketing Performance
CREATE TABLE MarketingPerformance (
    performance_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    leads_generated INT,
    conversions INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (performance_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 65. Ad Spend Analysis
CREATE TABLE AdSpendAnalysis (
    analysis_id INT NOT NULL AUTO_INCREMENT,
    ad_campaign_id INT NOT NULL,
    total_spend DECIMAL(10, 2),
    leads_generated INT,
    conversions INT,
    PRIMARY KEY (analysis_id),
    FOREIGN KEY (ad_campaign_id) REFERENCES AdCampaigns(ad_campaign_id)
);

-- 66. Conversion Rates
CREATE TABLE ConversionRates (
    rate_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    conversion_rate DECIMAL(5, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (rate_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 67. Customer Retention
CREATE TABLE CustomerRetention (
    retention_id INT NOT NULL AUTO_INCREMENT,
    lead_id INT NOT NULL,
    retention_score DECIMAL(5, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (retention_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 68. Churn Analysis
CREATE TABLE ChurnAnalysis (
    churn_id INT NOT NULL AUTO_INCREMENT,
    lead_id INT NOT NULL,
    churn_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (churn_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 69. Customer Loyalty Programs
CREATE TABLE CustomerLoyaltyPrograms (
    program_id INT NOT NULL AUTO_INCREMENT,
    program_name VARCHAR(100),
    points_required INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (program_id)
);

-- 70. Loyalty Program Members
CREATE TABLE LoyaltyProgramMembers (
    member_id INT NOT NULL AUTO_INCREMENT,
    program_id INT NOT NULL,
    lead_id INT NOT NULL,
    points_earned INT DEFAULT 0,
    PRIMARY KEY (member_id),
    FOREIGN KEY (program_id) REFERENCES CustomerLoyaltyPrograms(program_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 71. Loyalty Redemptions
CREATE TABLE LoyaltyRedemptions (
    redemption_id INT NOT NULL AUTO_INCREMENT,
    member_id INT NOT NULL,
    redeemed_points INT,
    redemption_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (redemption_id),
    FOREIGN KEY (member_id) REFERENCES LoyaltyProgramMembers(member_id)
);

-- 72. Event Sponsorships
CREATE TABLE EventSponsorships (
    sponsorship_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    sponsor_name VARCHAR(100),
    sponsorship_amount DECIMAL(10, 2),
    PRIMARY KEY (sponsorship_id),
    FOREIGN KEY (event_id) REFERENCES EventMarketing(event_id)
);

-- 73. Customer Success Stories
CREATE TABLE CustomerSuccessStories (
    story_id INT NOT NULL AUTO_INCREMENT,
    lead_id INT NOT NULL,
    success_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (story_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 74. Marketing Technology Stack
CREATE TABLE MarketingTechStack (
    tech_id INT NOT NULL AUTO_INCREMENT,
    tech_name VARCHAR(100),
    usage_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (tech_id)
);

-- 75. Tech Stack Usage
CREATE TABLE TechStackUsage (
    usage_id INT NOT NULL AUTO_INCREMENT,
    tech_id INT NOT NULL,
    campaign_id INT NOT NULL,
    PRIMARY KEY (usage_id),
    FOREIGN KEY (tech_id) REFERENCES MarketingTechStack(tech_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 76. Social Media Analytics
CREATE TABLE SocialMediaAnalytics (
    analytics_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    platform VARCHAR(100),
    metrics TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (analytics_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 77. Content Performance
CREATE TABLE ContentPerformance (
    performance_id INT NOT NULL AUTO_INCREMENT,
    piece_id INT NOT NULL,
    metrics TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (performance_id),
    FOREIGN KEY (piece_id) REFERENCES ContentPieces(piece_id)
);

-- 78. Lead Scoring
CREATE TABLE LeadScoring (
    score_id INT NOT NULL AUTO_INCREMENT,
    lead_id INT NOT NULL,
    score INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (score_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 79. Account Based Marketing
CREATE TABLE AccountBasedMarketing (
    abm_id INT NOT NULL AUTO_INCREMENT,
    account_name VARCHAR(100),
    target_audience VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (abm_id)
);

-- 80. ABM Engagements
CREATE TABLE ABMEngagements (
    engagement_id INT NOT NULL AUTO_INCREMENT,
    abm_id INT NOT NULL,
    lead_id INT NOT NULL,
    engagement_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (engagement_id),
    FOREIGN KEY (abm_id) REFERENCES AccountBasedMarketing(abm_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 81. Marketing KPIs
CREATE TABLE MarketingKPIs (
    kpi_id INT NOT NULL AUTO_INCREMENT,
    kpi_name VARCHAR(100),
    target_value DECIMAL(10, 2),
    actual_value DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (kpi_id)
);

-- 82. KPI Tracking
CREATE TABLE KPITracking (
    tracking_id INT NOT NULL AUTO_INCREMENT,
    kpi_id INT NOT NULL,
    tracked_date DATE,
    value DECIMAL(10, 2),
    PRIMARY KEY (tracking_id),
    FOREIGN KEY (kpi_id) REFERENCES MarketingKPIs(kpi_id)
);

-- 83. Digital Marketing Strategy
CREATE TABLE DigitalMarketingStrategy (
    strategy_id INT NOT NULL AUTO_INCREMENT,
    strategy_name VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (strategy_id)
);

-- 84. Strategy Implementation
CREATE TABLE VTStratImplement (
    implementation_id INT NOT NULL AUTO_INCREMENT,
    strategy_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (implementation_id),
    FOREIGN KEY (strategy_id) REFERENCES DigitalMarketingStrategy(strategy_id)
);

-- 85. Customer Acquisition
CREATE TABLE CustomerAcquisition (
    acquisition_id INT NOT NULL AUTO_INCREMENT,
    lead_id INT NOT NULL,
    acquisition_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (acquisition_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 86. Customer Retention Programs
CREATE TABLE CustomerRetentionPrograms (
    retention_program_id INT NOT NULL AUTO_INCREMENT,
    program_name VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (retention_program_id)
);

-- 87. Retention Program Participation
CREATE TABLE RetentionProgramParticipation (
    participation_id INT NOT NULL AUTO_INCREMENT,
    retention_program_id INT NOT NULL,
    lead_id INT NOT NULL,
    PRIMARY KEY (participation_id),
    FOREIGN KEY (retention_program_id) REFERENCES CustomerRetentionPrograms(retention_program_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 88. Customer Segmentation Criteria
CREATE TABLE CustomerSegmentationCriteria (
    criteria_id INT NOT NULL AUTO_INCREMENT,
    segment_id INT NOT NULL,
    criteria_text TEXT,
    PRIMARY KEY (criteria_id),
    FOREIGN KEY (segment_id) REFERENCES CustomerSegmentation(segment_id)
);

-- 89. Audience Insights
CREATE TABLE AudienceInsights (
    insight_id INT NOT NULL AUTO_INCREMENT,
    segment_id INT NOT NULL,
    insight_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (insight_id),
    FOREIGN KEY (segment_id) REFERENCES CustomerSegmentation(segment_id)
);

-- 90. Marketing Workshops
CREATE TABLE MarketingWorkshops (
    workshop_id INT NOT NULL AUTO_INCREMENT,
    workshop_name VARCHAR(100),
    date DATE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (workshop_id)
);

-- 91. Workshop Registrations
CREATE TABLE WorkshopRegistrations (
    registration_id INT NOT NULL AUTO_INCREMENT,
    workshop_id INT NOT NULL,
    lead_id INT NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (registration_id),
    FOREIGN KEY (workshop_id) REFERENCES MarketingWorkshops(workshop_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 92. Marketing Training
CREATE TABLE MarketingTraining (
    training_id INT NOT NULL AUTO_INCREMENT,
    training_name VARCHAR(100),
    training_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (training_id)
);

-- 93. Training Registrations
CREATE TABLE TrainingRegistrations (
    registration_id INT NOT NULL AUTO_INCREMENT,
    training_id INT NOT NULL,
    lead_id INT NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (registration_id),
    FOREIGN KEY (training_id) REFERENCES MarketingTraining(training_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 94. Marketing Partnerships
CREATE TABLE MarketingPartnerships (
    partnership_id INT NOT NULL AUTO_INCREMENT,
    partner_name VARCHAR(100),
    collaboration_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (partnership_id)
);

-- 95. Partnership Engagements
CREATE TABLE PartnershipEngagements (
    engagement_id INT NOT NULL AUTO_INCREMENT,
    partnership_id INT NOT NULL,
    lead_id INT NOT NULL,
    engagement_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (engagement_id),
    FOREIGN KEY (partnership_id) REFERENCES MarketingPartnerships(partnership_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 96. Marketing Research
CREATE TABLE MarketingResearch (
    research_id INT NOT NULL AUTO_INCREMENT,
    topic VARCHAR(100),
    findings TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (research_id)
);

-- 97. Research Collaborations
CREATE TABLE ResearchCollaborations (
    collaboration_id INT NOT NULL AUTO_INCREMENT,
    research_id INT NOT NULL,
    partner_name VARCHAR(100),
    PRIMARY KEY (collaboration_id),
    FOREIGN KEY (research_id) REFERENCES MarketingResearch(research_id)
);

-- 98. Campaign Trends
CREATE TABLE CampaignTrends (
    trend_id INT NOT NULL AUTO_INCREMENT,
    campaign_id INT NOT NULL,
    trend_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (trend_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);

-- 99. Marketing Events Feedback
CREATE TABLE MarketingEventsFeedback (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    lead_id INT NOT NULL,
    feedback_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (event_id) REFERENCES MarketingEvents(event_id),
    FOREIGN KEY (lead_id) REFERENCES Leads(lead_id)
);

-- 100. Marketing Goals
CREATE TABLE MarketingGoals (
    goal_id INT NOT NULL AUTO_INCREMENT,
    goal_name VARCHAR(100),
    target_value DECIMAL(10, 2),
    actual_value DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (goal_id)
);

-- 1. Tutors
CREATE TABLE Tutors (
    tutor_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    subject_specialty VARCHAR(100),
    experience_years INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (tutor_id)
);

-- 2. Tutor Profiles
CREATE TABLE TutorProfiles (
    profile_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    bio TEXT,
    profile_picture VARCHAR(255),
    PRIMARY KEY (profile_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 3. Subjects
CREATE TABLE Subjects (
    subject_id INT NOT NULL AUTO_INCREMENT,
    subject_name VARCHAR(100),
    PRIMARY KEY (subject_id)
);

-- 4. Tutor_Subjects
CREATE TABLE Tutor_Subjects (
    tutor_subject_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    subject_id INT NOT NULL,
    PRIMARY KEY (tutor_subject_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id)
);

-- 5. StudentsVT
CREATE TABLE StudentsVT (
    student_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id)
);

-- 6. Student_Enrollments
CREATE TABLE Student_Enrollments (
    enrollment_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (enrollment_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 7. VTCourses2
CREATE TABLE VTCourses2 (
    course_id INT NOT NULL AUTO_INCREMENT,
    course_name VARCHAR(100),
    course_description TEXT,
    PRIMARY KEY (course_id)
);

-- 8. Tutor_Schedules
CREATE TABLE Tutor_Schedules (
    schedule_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    available_day VARCHAR(10),
    available_time TIME,
    PRIMARY KEY (schedule_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 9. TutoringSessionsTwo
CREATE TABLE TutoringSessionsTwo (
    session_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    session_date TIMESTAMP,
    session_duration INT, -- in minutes
    PRIMARY KEY (session_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id),
    FOREIGN KEY (course_id) REFERENCES VTCourses2(course_id)
);

-- 10. Session_Feedback
CREATE TABLE Session_Feedback (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    session_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comments TEXT,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (session_id) REFERENCES TutoringSessionsTwo(session_id)
);

-- 11. Tutor_Ratings
CREATE TABLE Tutor_Ratings (
    rating_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    student_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (rating_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 12. Tutor_Availability
CREATE TABLE Tutor_Availability (
    availability_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    date DATE,
    available BOOLEAN,
    PRIMARY KEY (availability_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 13. PaymentsVT
CREATE TABLE PaymentsVT (
    payment_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    session_id INT NOT NULL,
    amount DECIMAL(10, 2),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (payment_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id),
    FOREIGN KEY (session_id) REFERENCES TutoringSessionsTwo(session_id)
);

-- 14. Discounts
CREATE TABLE Discounts (
    discount_id INT NOT NULL AUTO_INCREMENT,
    discount_code VARCHAR(50),
    discount_percentage DECIMAL(5, 2),
    valid_until DATE,
    PRIMARY KEY (discount_id)
);

-- 15. Tutor_Reviews
CREATE TABLE Tutor_Reviews (
    review_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 16. TutoringEvents
CREATE TABLE TutoringEvents (
    event_id INT NOT NULL AUTO_INCREMENT,
    event_name VARCHAR(100),
    event_date DATE,
    event_location VARCHAR(255),
    PRIMARY KEY (event_id)
);

-- 17. Event_Attendees
CREATE TABLE Event_Attendees (
    attendee_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (attendee_id),
    FOREIGN KEY (event_id) REFERENCES TutoringEvents(event_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 18. TutoringNotify
CREATE TABLE TutoringNotify (
    notification_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL, -- Can be student or tutor
    notification_text TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (notification_id)
);

-- 19. Tutor_Qualifications
CREATE TABLE Tutor_Qualifications (
    qualification_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    qualification_name VARCHAR(100),
    institution VARCHAR(100),
    year_obtained INT,
    PRIMARY KEY (qualification_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 20. Tutor_Experience
CREATE TABLE Tutor_Experience (
    experience_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    previous_employer VARCHAR(100),
    position VARCHAR(100),
    years_worked INT,
    PRIMARY KEY (experience_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 21. Tutor_Specialties
CREATE TABLE Tutor_Specialties (
    specialty_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    specialty_name VARCHAR(100),
    PRIMARY KEY (specialty_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 22. Tutor_Skills
CREATE TABLE Tutor_Skills (
    skill_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    skill_name VARCHAR(100),
    PRIMARY KEY (skill_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 23. Tutor_Timings
CREATE TABLE Tutor_Timings (
    timing_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    timing_start TIME,
    timing_end TIME,
    PRIMARY KEY (timing_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 24. Tutor_Languages
CREATE TABLE Tutor_Languages (
    language_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    language_name VARCHAR(100),
    PRIMARY KEY (language_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 25. Session_Notes
CREATE TABLE Session_Notes (
    note_id INT NOT NULL AUTO_INCREMENT,
    session_id INT NOT NULL,
    note_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (note_id),
    FOREIGN KEY (session_id) REFERENCES TutoringSessionsTwo(session_id)
);

-- 26. Tutor_Certifications
CREATE TABLE Tutor_Certifications_Two (
    certification_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    certification_name VARCHAR(100),
    issuing_organization VARCHAR(100),
    year_obtained INT,
    PRIMARY KEY (certification_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 27. Session_Reschedule
CREATE TABLE Session_Reschedule (
    reschedule_id INT NOT NULL AUTO_INCREMENT,
    session_id INT NOT NULL,
    new_session_date TIMESTAMP,
    PRIMARY KEY (reschedule_id),
    FOREIGN KEY (session_id) REFERENCES TutoringSessionsTwo(session_id)
);

-- 28. Tutor_SocialMedia
CREATE TABLE Tutor_SocialMedia (
    social_media_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    platform VARCHAR(50),
    profile_url VARCHAR(255),
    PRIMARY KEY (social_media_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 29. Tutor_Articles
CREATE TABLE Tutor_Articles (
    article_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    article_title VARCHAR(100),
    article_content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (article_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 30. Tutor_Blog
CREATE TABLE Tutor_Blog (
    blog_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    blog_title VARCHAR(100),
    blog_content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (blog_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 31. Tutor_Media
CREATE TABLE Tutor_Media (
    media_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    media_type VARCHAR(50), -- e.g., video, image
    media_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (media_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 32. Tutor_Projects
CREATE TABLE Tutor_Projects (
    project_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    project_title VARCHAR(100),
    project_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (project_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 33. Tutor_Events
CREATE TABLE Tutor_Events (
    tutor_event_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    event_id INT NOT NULL,
    PRIMARY KEY (tutor_event_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (event_id) REFERENCES TutoringEvents(event_id)
);

-- 34. Tutor_Connections
CREATE TABLE Tutor_Connections (
    connection_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    student_id INT NOT NULL,
    connection_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (connection_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 35. Tutor_SuccessStories
CREATE TABLE Tutor_SuccessStories (
    story_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    student_id INT NOT NULL,
    story_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (story_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 36. Tutor_Videos
CREATE TABLE Tutor_Videos (
    video_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    video_title VARCHAR(100),
    video_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (video_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 37. Tutor_Questions
CREATE TABLE Tutor_Questions (
    question_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    question_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (question_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 38. Tutor_Answers
CREATE TABLE Tutor_Answers (
    answer_id INT NOT NULL AUTO_INCREMENT,
    question_id INT NOT NULL,
    answer_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (answer_id),
    FOREIGN KEY (question_id) REFERENCES Tutor_Questions(question_id)
);

-- 39. Tutor_Categories
CREATE TABLE Tutor_Categories (
    category_id INT NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(100),
    PRIMARY KEY (category_id)
);

-- 40. Tutor_Category_Assignment
CREATE TABLE Tutor_Category_Assignment (
    assignment_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (assignment_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (category_id) REFERENCES Tutor_Categories(category_id)
);

-- 41. Tutor_Articles_Comments
CREATE TABLE Tutor_Articles_Comments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    article_id INT NOT NULL,
    student_id INT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (article_id) REFERENCES Tutor_Articles(article_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 42. Tutor_Blog_Comments
CREATE TABLE Tutor_Blog_Comments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    blog_id INT NOT NULL,
    student_id INT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (blog_id) REFERENCES Tutor_Blog(blog_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 43. Tutor_Resources
CREATE TABLE Tutor_Resources (
    resource_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    resource_name VARCHAR(100),
    resource_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (resource_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 44. Tutor_Galleries
CREATE TABLE Tutor_Galleries (
    gallery_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    gallery_title VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (gallery_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 45. Gallery_Images
CREATE TABLE Gallery_Images (
    image_id INT NOT NULL AUTO_INCREMENT,
    gallery_id INT NOT NULL,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (image_id),
    FOREIGN KEY (gallery_id) REFERENCES Tutor_Galleries(gallery_id)
);

-- 46. Tutor_Policies
CREATE TABLE Tutor_Policies (
    policy_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    policy_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (policy_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 47. Tutor_Reports
CREATE TABLE Tutor_Reports (
    report_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    report_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (report_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 48. Tutor_Awards
CREATE TABLE Tutor_Awards (
    award_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    award_name VARCHAR(100),
    award_year INT,
    PRIMARY KEY (award_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 49. Tutor_Banners
CREATE TABLE Tutor_Banners (
    banner_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    banner_image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (banner_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 50. Tutor_SuccessMetrics
CREATE TABLE Tutor_SuccessMetrics (
    metric_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    metric_name VARCHAR(100),
    metric_value DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (metric_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 51. Tutor_Projects_Comments
CREATE TABLE Tutor_Projects_Comments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    project_id INT NOT NULL,
    student_id INT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (project_id) REFERENCES Tutor_Projects(project_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 52. Tutor_Media_Comments
CREATE TABLE Tutor_Media_Comments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    media_id INT NOT NULL,
    student_id INT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (media_id) REFERENCES Tutor_Media(media_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 53. Tutor_Event_Comments
CREATE TABLE Tutor_Event_Comments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    student_id INT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (event_id) REFERENCES TutoringEvents(event_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 54. Tutor_Session_Tags
CREATE TABLE Tutor_Session_Tags (
    tag_id INT NOT NULL AUTO_INCREMENT,
    session_id INT NOT NULL,
    tag_name VARCHAR(100),
    PRIMARY KEY (tag_id),
    FOREIGN KEY (session_id) REFERENCES TutoringSessionsTwo(session_id)
);

-- 55. Tutor_Meeting
CREATE TABLE Tutor_Meeting (
    meeting_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    student_id INT NOT NULL,
    meeting_date TIMESTAMP,
    meeting_duration INT,
    PRIMARY KEY (meeting_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 56. Tutor_Video_Sessions
CREATE TABLE Tutor_Video_Sessions (
    video_session_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    student_id INT NOT NULL,
    session_date TIMESTAMP,
    PRIMARY KEY (video_session_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 57. Tutor_Workshops
CREATE TABLE Tutor_Workshops (
    workshop_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    workshop_name VARCHAR(100),
    workshop_description TEXT,
    workshop_date TIMESTAMP,
    PRIMARY KEY (workshop_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 58. Tutor_Forum
CREATE TABLE Tutor_Forum (
    forum_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    forum_topic VARCHAR(100),
    forum_content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (forum_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 59. Tutor_Forum_Comments
CREATE TABLE Tutor_Forum_Comments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    forum_id INT NOT NULL,
    student_id INT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (forum_id) REFERENCES Tutor_Forum(forum_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 60. Tutor_Notes
CREATE TABLE Tutor_Notes (
    note_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    note_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (note_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 61. Tutor_Articles_Likes
CREATE TABLE Tutor_Articles_Likes (
    like_id INT NOT NULL AUTO_INCREMENT,
    article_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (like_id),
    FOREIGN KEY (article_id) REFERENCES Tutor_Articles(article_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 62. Tutor_Blog_Likes
CREATE TABLE Tutor_Blog_Likes (
    like_id INT NOT NULL AUTO_INCREMENT,
    blog_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (like_id),
    FOREIGN KEY (blog_id) REFERENCES Tutor_Blog(blog_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 63. Tutor_Projects_Likes
CREATE TABLE Tutor_Projects_Likes (
    like_id INT NOT NULL AUTO_INCREMENT,
    project_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (like_id),
    FOREIGN KEY (project_id) REFERENCES Tutor_Projects(project_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 64. Tutor_Certifications_Comments
CREATE TABLE Tutor_Certifications_Comments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    certification_id INT NOT NULL,
    student_id INT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (certification_id) REFERENCES Tutor_Certifications_Two(certification_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 65. Tutor_Awards_Comments
CREATE TABLE Tutor_Awards_Comments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    award_id INT NOT NULL,
    student_id INT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (award_id) REFERENCES Tutor_Awards(award_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 66. Tutor_Galleries_Comments
CREATE TABLE Tutor_Galleries_Comments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    gallery_id INT NOT NULL,
    student_id INT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (gallery_id) REFERENCES Tutor_Galleries(gallery_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 67. Tutor_Resources_Comments
CREATE TABLE Tutor_Resources_Comments (
    comment_id INT NOT NULL AUTO_INCREMENT,
    resource_id INT NOT NULL,
    student_id INT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id),
    FOREIGN KEY (resource_id) REFERENCES Tutor_Resources(resource_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 68. Tutor_SocialMedia_Likes
CREATE TABLE Tutor_SocialMedia_Likes (
    like_id INT NOT NULL AUTO_INCREMENT,
    social_media_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (like_id),
    FOREIGN KEY (social_media_id) REFERENCES Tutor_SocialMedia(social_media_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 69. Tutor_Financials
CREATE TABLE Tutor_Financials (
    financial_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    income DECIMAL(10, 2),
    expenses DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (financial_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 70. Tutor_Statistics
CREATE TABLE Tutor_Statistics (
    statistic_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    session_count INT,
    feedback_count INT,
    success_rate DECIMAL(5, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (statistic_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 71. Tutor_IndustryConnections
CREATE TABLE Tutor_IndustryConnections (
    connection_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    organization_name VARCHAR(100),
    contact_person VARCHAR(100),
    contact_info VARCHAR(100),
    PRIMARY KEY (connection_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 72. Tutor_Referrals
CREATE TABLE Tutor_Referrals (
    referral_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    referred_student_id INT NOT NULL,
    referral_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (referral_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (referred_student_id) REFERENCES StudentsVT(student_id)
);

-- 73. Tutor_Meeting_Notes
CREATE TABLE Tutor_Meeting_Notes (
    meeting_note_id INT NOT NULL AUTO_INCREMENT,
    meeting_id INT NOT NULL,
    note_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (meeting_note_id),
    FOREIGN KEY (meeting_id) REFERENCES Tutor_Meeting(meeting_id)
);

-- 74. Tutor_Languages_Spoken
CREATE TABLE Tutor_Languages_Spoken (
    spoken_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    language_name VARCHAR(100),
    PRIMARY KEY (spoken_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 75. Tutor_Interactions
CREATE TABLE Tutor_Interactions (
    interaction_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    student_id INT NOT NULL,
    interaction_type VARCHAR(100), -- e.g., call, email
    interaction_date TIMESTAMP,
    PRIMARY KEY (interaction_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (student_id) REFERENCES StudentsVT(student_id)
);

-- 76. Tutor_Feedback
CREATE TABLE Tutor_Feedback (
    feedback_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    feedback_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (feedback_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 77. Tutor_Collaborations
CREATE TABLE Tutor_Collaborations (
    collaboration_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    project_name VARCHAR(100),
    project_description TEXT,
    PRIMARY KEY (collaboration_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 78. Tutor_Conferences
CREATE TABLE Tutor_Conferences (
    conference_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    conference_name VARCHAR(100),
    conference_date DATE,
    PRIMARY KEY (conference_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 79. Tutor_Podcasts
CREATE TABLE Tutor_Podcasts (
    podcast_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    podcast_title VARCHAR(100),
    podcast_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (podcast_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 80. Tutor_Webinars
CREATE TABLE Tutor_Webinars (
    webinar_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    webinar_title VARCHAR(100),
    webinar_date TIMESTAMP,
    PRIMARY KEY (webinar_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 81. Tutor_Websites
CREATE TABLE Tutor_Websites (
    website_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    website_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (website_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 82. Tutor_SocialMediaMetrics
CREATE TABLE Tutor_SocialMediaMetrics (
    metric_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    platform VARCHAR(50),
    followers_count INT,
    engagement_rate DECIMAL(5, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (metric_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 83. Tutor_Ads
CREATE TABLE Tutor_Ads (
    ad_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    ad_content TEXT,
    ad_platform VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ad_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 84. Tutor_AdMetrics
CREATE TABLE Tutor_AdMetrics (
    metric_id INT NOT NULL AUTO_INCREMENT,
    ad_id INT NOT NULL,
    clicks INT,
    impressions INT,
    PRIMARY KEY (metric_id),
    FOREIGN KEY (ad_id) REFERENCES Tutor_Ads(ad_id)
);

-- 85. Tutor_Competitions
CREATE TABLE Tutor_Competitions (
    competition_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    competition_name VARCHAR(100),
    competition_date DATE,
    PRIMARY KEY (competition_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 86. Tutor_Networks
CREATE TABLE Tutor_Networks (
    network_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    network_name VARCHAR(100),
    PRIMARY KEY (network_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 87. Tutor_Partnerships
CREATE TABLE Tutor_Partnerships (
    partnership_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    partner_name VARCHAR(100),
    partnership_date TIMESTAMP,
    PRIMARY KEY (partnership_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 88. Tutor_Certifications
CREATE TABLE Tutor_Certifications (
    certification_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    certification_name VARCHAR(100),
    issued_date DATE,
    expiration_date DATE,
    PRIMARY KEY (certification_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 89. Tutor_TrainingPrograms
CREATE TABLE Tutor_TrainingPrograms (
    training_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    program_name VARCHAR(100),
    program_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (training_id)
);

-- 90. Tutor_FeedbackResponses
CREATE TABLE Tutor_FeedbackResponses (
    response_id INT NOT NULL AUTO_INCREMENT,
    feedback_id INT NOT NULL,
    response_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (response_id),
    FOREIGN KEY (feedback_id) REFERENCES Tutor_Feedback(feedback_id)
);

-- 91. Tutor_Mentorships
CREATE TABLE Tutor_Mentorships (
    mentorship_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    mentee_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (mentorship_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id),
    FOREIGN KEY (mentee_id) REFERENCES StudentsVT(student_id)
);

-- 92. Tutor_Resources
CREATE TABLE Tutor_Resources_Two (
    resource_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    resource_title VARCHAR(100),
    resource_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (resource_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 93. Tutor_Articles
CREATE TABLE Tutor_Articles_Two (
    article_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    article_title VARCHAR(100),
    article_content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (article_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 94. Tutor_TrainingSessions
CREATE TABLE Tutor_TrainingSessions (
    session_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    session_date TIMESTAMP,
    session_topic VARCHAR(100),
    PRIMARY KEY (session_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 95. Tutor_Videos
CREATE TABLE Tutor_Videos_Two (
    video_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    video_title VARCHAR(100),
    video_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (video_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 96. Tutor_AudioLectures
CREATE TABLE Tutor_AudioLectures (
    audio_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    audio_title VARCHAR(100),
    audio_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (audio_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 97. Tutor_BookRecommendations
CREATE TABLE Tutor_BookRecommendations (
    recommendation_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    book_title VARCHAR(100),
    author VARCHAR(100),
    PRIMARY KEY (recommendation_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 98. Tutor_FeedbackSurveys
CREATE TABLE Tutor_FeedbackSurveys (
    survey_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    survey_title VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (survey_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 99. Tutor_EventParticipation
CREATE TABLE Tutor_EventParticipation (
    participation_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    event_name VARCHAR(100),
    event_date DATE,
    PRIMARY KEY (participation_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);

-- 100. Tutor_Goals
CREATE TABLE Tutor_Goals (
    goal_id INT NOT NULL AUTO_INCREMENT,
    tutor_id INT NOT NULL,
    goal_description TEXT,
    target_date DATE,
    PRIMARY KEY (goal_id),
    FOREIGN KEY (tutor_id) REFERENCES Tutors(tutor_id)
);