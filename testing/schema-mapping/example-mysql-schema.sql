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