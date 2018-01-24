# 关于jOOQ 七个步骤快速入门
> jOOQ: The easiest way to write SQL in Java

jOOQ是一个基于Java编写SQL的工具包，具有：简单、轻量、函数式编程写SQL等独特优势，非常适合敏捷快速迭代开发。

# 初见jOOQ
使用jOOQ，SQL看起来好像是由Java原生支持的，保留SQL原有的简单。

SQL语句：
```SQL
SELECT AUTHOR.FIRST_NAME, AUTHOR.LAST_NAME, COUNT(*)
    FROM AUTHOR
    JOIN BOOK ON AUTHOR.ID = BOOK.AUTHOR_ID
   WHERE BOOK.LANGUAGE = 'DE'
     AND BOOK.PUBLISHED > DATE '2008-01-01'
GROUP BY AUTHOR.FIRST_NAME, AUTHOR.LAST_NAME
  HAVING COUNT(*) > 5
ORDER BY AUTHOR.LAST_NAME ASC NULLS FIRST
   LIMIT 2
  OFFSET 1
```
Java代码：
```java
create.select(AUTHOR.FIRST_NAME, AUTHOR.LAST_NAME, count())
      .from(AUTHOR)
      .join(BOOK).on(AUTHOR.ID.equal(BOOK.AUTHOR_ID))
      .where(BOOK.LANGUAGE.eq("DE"))
      .and(BOOK.PUBLISHED.gt(date("2008-01-01")))
      .groupBy(AUTHOR.FIRST_NAME, AUTHOR.LAST_NAME)
      .having(count().gt(5))
      .orderBy(AUTHOR.LAST_NAME.asc().nullsFirst())
      .limit(2)
      .offset(1)
```
# 一、准备
如果还没有下载，请下载jOOQ：<br>
http://www.jooq.org/download <br>
或者，可是使用Maven：
```xml
<dependency>
  <groupId>org.jooq</groupId>
  <artifactId>jooq</artifactId>
  <version>3.9.5</version>
</dependency>
<dependency>
  <groupId>org.jooq</groupId>
  <artifactId>jooq-meta</artifactId>
  <version>3.9.5</version>
</dependency>
<dependency>
  <groupId>org.jooq</groupId>
  <artifactId>jooq-codegen</artifactId>
  <version>3.9.5</version>
</dependency>
```
# 二、创建数据库
我们要创建一个名为library的数据库，和一个author表，在表中插入zhang3,li4数据。
```sql
CREATE DATABASE `library`;

USE `library`;

CREATE TABLE `author` (
  `id` int NOT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
);

INSERT INTO `author` (`id`, `first_name`, `last_name`) VALUES ('1', '3', 'zhang'), ('2', '4', 'li');
```
# 三、代码生成
在这一步中，我们将使用jOOQ的命令行工具生成映射到author表的Java类。 
有关jOOQ代码生成器的更详细信息，请参见：<br>
<a href="http://www.jooq.org/doc/3.9/manual-single-page/#code-generation" target=_blank>jOOQ manual pages about setting up the code generator</a><br>
代码生成的最简单的方法是将jOOQ的3个jar文件和MySQL Connector jar文件复制到一个临时目录（本示例中目录是test-generated）， 然后创建一个如下所示的library.xml（名字随意修改）：
```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<configuration xmlns="http://www.jooq.org/xsd/jooq-codegen-3.9.2.xsd">
  <!-- Configure the database connection here -->
  <jdbc>
    <driver>com.mysql.jdbc.Driver</driver>
    <!-- 数据库url -->
    <url>jdbc:mysql://localhost:3306/library?useUnicode=true&amp;characterEncoding=UTF-8</url>
    <!-- 数据库账号 -->
    <user>root</user>
    <!-- 数据库账号密码 -->
    <password>123456</password>
  </jdbc>

  <generator>
    <!-- The default code generator. You can override this one, to generate your own code style.
         Supported generators:
         - org.jooq.util.JavaGenerator
         - org.jooq.util.ScalaGenerator
         Defaults to org.jooq.util.JavaGenerator -->
    <name>org.jooq.util.JavaGenerator</name>

    <database>
      <!-- The database type. The format here is:
           org.util.[database].[database]Database -->
      <name>org.jooq.util.mysql.MySQLDatabase</name>

      <!-- The database schema (or in the absence of schema support, in your RDBMS this
           can be the owner, user, database name) to be generated -->
      <inputSchema>library</inputSchema>

      <!-- All elements that are generated from your schema
           (A Java regular expression. Use the pipe to separate several expressions)
           Watch out for case-sensitivity. Depending on your database, this might be important! -->
      <includes>.*</includes>

      <!-- All elements that are excluded from your schema
           (A Java regular expression. Use the pipe to separate several expressions).
           Excludes match before includes, i.e. excludes have a higher priority -->
      <excludes></excludes>
    </database>

    <target>
      <!-- The destination package of your generated classes (within the destination directory) -->
      <!-- 生成的包名，生成的类在此包下 -->
      <packageName>test.generated</packageName>

      <!-- The destination directory of your generated classes. Using Maven directory layout here -->
      <!-- 输出的目录 -->
      <directory>C:/workspace/jOOQ-User-Manual/jooq-tutorials-1/src/main/java</directory>
    </target>
  </generator>
</configuration>
```
在Windows中，cd到test-generated目录，执行以下命令：

> 注意jar包的版本号与您本地对应上，在这个例子中，jOOQ使用3.9.5，MySQL使用5.1.30。
```java
java -classpath jooq-3.9.5.jar;jooq-meta-3.9.5.jar;jooq-codegen-3.9.5.jar;mysql-connector-java-5.1.30.jar; org.jooq.util.GenerationTool library.xml
```
UNIX / Linux / Mac中：
```java
java -classpath jooq-3.9.5.jar:jooq-meta-3.9.5.jar:jooq-codegen-3.9.5.jar:mysql-connector-java-5.1.30.jar: org.jooq.util.GenerationTool library.xml
```
如果一切正常，您应该在控制台输出中看到这些信息：
```
七月 30, 2017 1:12:51 下午 org.jooq.tools.JooqLogger info
信息: Initialising properties  : library.xml
七月 30, 2017 1:12:51 下午 org.jooq.tools.JooqLogger info
信息: No <inputCatalog/> was provided. Generating ALL available catalogs instead.
七月 30, 2017 1:12:51 下午 org.jooq.tools.JooqLogger info
信息: License parameters
七月 30, 2017 1:12:51 下午 org.jooq.tools.JooqLogger info
信息: ----------------------------------------------------------
七月 30, 2017 1:12:51 下午 org.jooq.tools.JooqLogger info
信息:   Thank you for using jOOQ and jOOQ‘s code generator
七月 30, 2017 1:12:51 下午 org.jooq.tools.JooqLogger info
信息:
七月 30, 2017 1:12:51 下午 org.jooq.tools.JooqLogger info
信息: Database parameters
七月 30, 2017 1:12:51 下午 org.jooq.tools.JooqLogger info
信息: ----------------------------------------------------------
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   dialect                : MYSQL
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   URL                    : jdbc:mysql://localhost:3306/library?useUnicode=true&characterEncoding=UTF-8
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   target dir             : C:/workspace/jOOQ-User-Manual/jooq-tutorials-1/src/main/java
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   target package         : test.generated
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   includes               : [.*]
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   excludes               : []
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   includeExcludeColumns  : false
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: ----------------------------------------------------------
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: JavaGenerator parameters
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: ----------------------------------------------------------
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   strategy               : class org.jooq.util.DefaultGeneratorStrategy
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   deprecated             : true
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   generated annotation   : true
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   JPA annotations        : false
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   validation annotations : false
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   instance fields        : true
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   sequences              : true
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   udts                   : true
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   routines               : true
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   tables                 : true
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   records                : true
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   pojos                  : false
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   immutable pojos        : false
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   interfaces             : false
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   immutable interfaces   : false
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   daos                   : false
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   relations              : true
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   table-valued functions : true
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:   global references      : true
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: ----------------------------------------------------------
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generation remarks
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: ----------------------------------------------------------
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: ----------------------------------------------------------
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generating catalogs      : Total: 1
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@  @@        @@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@
@@@@@@@@@@@@@@@@  @@  @@    @@@@@@@@@@
@@@@@@@@@@  @@@@  @@  @@    @@@@@@@@@@
@@@@@@@@@@        @@        @@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@        @@        @@@@@@@@@@
@@@@@@@@@@    @@  @@  @@@@  @@@@@@@@@@
@@@@@@@@@@    @@  @@  @@@@  @@@@@@@@@@
@@@@@@@@@@        @@  @  @  @@@@@@@@@@
@@@@@@@@@@        @@        @@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  Thank you for using jOOQ 3.9.5

七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: ARRAYs fetched           : 0 (0 included, 0 excluded)
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Enums fetched            : 0 (0 included, 0 excluded)
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Packages fetched         : 0 (0 included, 0 excluded)
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Routines fetched         : 0 (0 included, 0 excluded)
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Tables fetched           : 1 (1 included, 0 excluded)
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: No schema version is applied for catalog . Regenerating.
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generating catalog       : DefaultCatalog.java
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: ==========================================================
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generating schemata      : Total: 1
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: No schema version is applied for schema library. Regenerating.
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generating schema        : Library.java
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: ----------------------------------------------------------
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Sequences fetched        : 0 (0 included, 0 excluded)
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: UDTs fetched             : 0 (0 included, 0 excluded)
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generating tables
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Synthetic primary keys   : 0 (0 included, 0 excluded)
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Overriding primary keys  : 1 (0 included, 1 excluded)
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generating table         : Author.java [input=author, output=author, pk=KEY_author_PRIMARY]
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Tables generated         : Total: 819.168ms
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generating table references
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Table refs generated     : Total: 827.491ms, +8.323ms
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generating Keys
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Keys generated           : Total: 835.486ms, +7.995ms
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generating table records
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generating record        : AuthorRecord.java
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Table records generated  : Total: 854.667ms, +19.18ms
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Domains fetched          : 0 (0 included, 0 excluded)
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Generation finished: library: Total: 860.822ms, +6.155ms
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息:
七月 30, 2017 1:12:52 下午 org.jooq.tools.JooqLogger info
信息: Removing excess files
```
# 四、连接到您的数据库
我们在工程中编写一个测试类Main.java：
```java
package test.generated;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * 测试类
 * Created by jan on 2017/7/30.
 */
public class Main {
    public static void main(String[] args) {
        // 用户名
        String userName = "root";
        // 密码
        String password = "123456";
        // mysql连接url
        String url = "jdbc:mysql://localhost:3306/library?useUnicode=true&characterEncoding=UTF-8";

        // Connection is the only JDBC resource that we need
        // PreparedStatement and ResultSet are handled by jOOQ, internally
        try (Connection conn = DriverManager.getConnection(url, userName, password)) {
            // ...
        }

        // For the sake of this tutorial, let's keep exception handling simple
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```
这是一个标准的JDBC MySQL连接代码。

# 五、查询
我们使用jOOQ的DSL构建出一个简单查询：
```java
DSLContext create = DSL.using(conn, SQLDialect.MYSQL);
Result<Record> result = create.select().from(AUTHOR).fetch();
```
传入Connection连接对象、数据方言得到一个DSLContext的实例，然后使用DSL对象查询得到一个Result对象。

> 注意：DSLContext不会主动关闭连接，需要我们手动关闭。

# 六、输出结果
得到Result对象后，循环输出结果集：
```java
for (Record r : result) {
    Integer id = r.getValue(AUTHOR.ID);
    String firstName = r.getValue(AUTHOR.FIRST_NAME);
    String lastName = r.getValue(AUTHOR.LAST_NAME);

    System.out.println("ID: " + id + " first name: " + firstName + " last name: " + lastName);
}
```
完成的代码应该是这样的：
```java
package test.generated;

import org.jooq.DSLContext;
import org.jooq.Record;
import org.jooq.Result;
import org.jooq.SQLDialect;
import org.jooq.impl.DSL;

import java.sql.Connection;
import java.sql.DriverManager;

import static test.generated.tables.Author.AUTHOR;

/**
 * 测试类
 * Created by jan on 2017/7/30.
 */
public class Main {
    public static void main(String[] args) {
        // 用户名
        String userName = "root";
        // 密码
        String password = "123456";
        // mysql连接url
        String url = "jdbc:mysql://localhost:3306/library?useUnicode=true&characterEncoding=UTF-8";

        // Connection is the only JDBC resource that we need
        // PreparedStatement and ResultSet are handled by jOOQ, internally
        try (Connection conn = DriverManager.getConnection(url, userName, password)) {
            DSLContext create = DSL.using(conn, SQLDialect.MYSQL);
            Result<Record> result = create.select().from(AUTHOR).fetch();

            for (Record r : result) {
                Integer id = r.getValue(AUTHOR.ID);
                String firstName = r.getValue(AUTHOR.FIRST_NAME);
                String lastName = r.getValue(AUTHOR.LAST_NAME);

                /**
                 * 控制台输出
                 * ID: 1 first name: 3 last name: zhang
                 * ID: 2 first name: 4 last name: li
                 */
                System.out.println("ID: " + id + " first name: " + firstName + " last name: " + lastName);
            }

            // 关闭连接对象
            conn.close();
        }
        // For the sake of this tutorial, let's keep exception handling simple
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```
# 七、更多示例

jOOQ已经是一个全面的SQL库，更多学习文档请参考：

http://www.jooq.org/learn

http://www.jooq.org/javadoc/l...

http://ikaisays.com/2011/11/0...