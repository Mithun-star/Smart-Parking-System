# Deployment Guide - Interview Experience Sharing Portal

This guide provides instructions to compile, deploy, and run the complete dynamic web application on **Eclipse Enterprise Edition** using **Apache Tomcat 10.x** and **MySQL 8.x**.

---

## 1. Prerequisites
Ensure you have the following installed on your system:
- **Java SE Development Kit (JDK) 17** (or JDK 11+)
- **Eclipse IDE for Enterprise Java and Web Developers**
- **Apache Tomcat 10.x** (Required for Jakarta EE Servlet API support)
- **MySQL Server 8.x** and **MySQL Workbench** (or command-line client)
- **MySQL Connector/J 8.x** JAR file (JDBC Driver)

---

## 2. Database Configuration
1. Open MySQL Workbench or your terminal and connect to your database.
2. Load and execute the `schema.sql` script located in the root of the project to create the database schema and populate it with sample seed records:
   ```sql
   SOURCE c:/Users/reddy/OneDrive/Documents/Smart_parking/Ajava/schema.sql;
   ```
3. By default, the Java database helper (`DBUtil.java`) connects using:
   - **URL**: `jdbc:mysql://localhost:3306/interview_portal_db`
   - **User**: `root`
   - **Password**: `admin`
   *Note: If your credentials differ, open `src/main/java/com/interviewportal/util/DBUtil.java` and modify the `USERNAME` and `PASSWORD` constants.*

---

## 3. Eclipse Project Import & Configuration
Follow these steps to import the project directory layout:

1. Open Eclipse and choose your workspace.
2. Select **File -> New -> Dynamic Web Project**.
3. Configure the following project parameters:
   - **Project Name**: `InterviewExperiencePortal`
   - **Target Runtime**: Click *New Runtime*, select **Apache Tomcat v10.x**, select your Tomcat installation directory, and click Finish.
   - **Dynamic Web Module Version**: `5.0` (matching Jakarta EE 9/Tomcat 10 specifications).
   - **Configuration**: Default Configuration for Apache Tomcat v10.x.
4. Click Next, leave Java Build Path settings default, click Next.
5. In **Web Module Configuration**:
   - Change **Content Directory** from `WebContent` to the root folder name where the JSP files reside, or configure Eclipse to map `WebContent` as the Web Content folder (Default is usually `WebContent` or `src/main/webapp`).
   - Check **Generate web.xml deployment descriptor** and click Finish.
6. Copy the generated code into Eclipse:
   - Copy the files under `src/main/java/` into the Java resources folder of the Eclipse project (`src/main/java`).
   - Copy the JSPs, `css/` directory, and `WEB-INF/web.xml` into the `WebContent` or `src/main/webapp` directory of your project.

---

## 4. JDBC Driver Setup
To allow Tomcat to locate the MySQL database connector:
1. Download **MySQL Connector/J 8.x** (e.g. `mysql-connector-j-8.x.x.jar`).
2. Copy the `.jar` file and paste it directly under the **`WebContent/WEB-INF/lib/`** directory of your Eclipse project. This guarantees the driver is packaged inside the WAR file and visible to the webapp classloader.
3. For runtime server configuration, you can also copy this JAR into the **`lib/`** folder of your installed Apache Tomcat directory (`tomcat-install-dir/lib/`).

---

## 5. Running the Web Application
1. Right-click on the Eclipse project (`InterviewExperiencePortal`).
2. Select **Run As -> Run on Server**.
3. Choose the configured **Tomcat v10.x** server and click Finish.
4. The server will spin up on port `8080` (unless configured otherwise), and a built-in browser window will open at:
   `http://localhost:8080/InterviewExperiencePortal/`
5. You can now use the portal:
   - Register a new user profile on `register.jsp`.
   - Log in as the new user or check administrator functionalities using username: `admin` and password: `admin123`.

---

## 6. Running the Swing Admin Dashboard
The Swing dashboard is a desktop application that bypasses the servlet container and connects to the MySQL database directly via JDBC.

### In Eclipse:
1. Navigate to `src/main/java/com/interviewportal/swing/SwingAdminDashboard.java` in the Package Explorer.
2. Right-click the file, select **Run As -> Java Application**.
3. The desktop GUI will appear.

### In CMD/PowerShell:
Ensure the MySQL connector jar is in your classpath. Navigate to your source output directory and execute:
```bash
java -cp ".;lib/mysql-connector-j-8.x.jar" com.interviewportal.swing.SwingAdminDashboard
```

---

## 7. Troubleshooting Common Errors
- **Error: `jakarta.servlet.ServletException` Class Not Found**
  - *Cause*: You are running Tomcat 9 or below, which uses the old `javax.servlet` packages instead of `jakarta.servlet`.
  - *Fix*: Install Tomcat 10.x or higher.
- **Error: `java.sql.SQLException: Access denied for user...`**
  - *Cause*: Wrong username or password configured in `DBUtil.java`.
  - *Fix*: Open `DBUtil.java` and adjust `USERNAME` and `PASSWORD` to match your local MySQL configuration.
- **Error: `com.mysql.cj.jdbc.Driver` ClassNotFoundException**
  - *Cause*: The MySQL connector JAR is missing from the classpath.
  - *Fix*: Verify the JAR is present in `WebContent/WEB-INF/lib/` and that you refreshed the project workspace.
- **Error: Port 8080 already in use**
  - *Cause*: Another process (or a zombie instance of Tomcat) is running on port 8080.
  - *Fix*: Kill the process using port 8080 via Task Manager, or change the connector port in Tomcat's `conf/server.xml`.
