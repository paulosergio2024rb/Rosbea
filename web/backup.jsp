<%@ page import="java.io.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
    // Dados de conexão
    String dbUser = "paulo";
    String dbPass = "6421";
    String dbName = "Rosbea";

    // Caminho para salvar o backup
    String backupDir = "/home/paulo/backups/"; // Já com seu usuário "paulo"

    // Criar pasta caso não exista
    File dir = new File(backupDir);
    if (!dir.exists()) {
        dir.mkdirs(); 
    }

    // Nome do arquivo de backup
    String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
    String backupFile = backupDir + "backup_Rosbea_" + timeStamp + ".sql";

    // Comando mysqldump
    String command = "mysqldump -u" + dbUser + " -p" + dbPass + " " + dbName + " > " + backupFile;

    try {
        // Executar o mysqldump
        Process process = Runtime.getRuntime().exec(new String[]{"/bin/bash", "-c", command});
        int processComplete = process.waitFor();

        if (processComplete == 0) {
            // Se o backup deu certo, preparar para download
            File file = new File(backupFile);
            if (file.exists()) {
                response.setContentType("application/octet-stream");
                response.setHeader("Content-Disposition", "attachment;filename=\"" + file.getName() + "\"");

                FileInputStream inStream = new FileInputStream(file);
                OutputStream outStream = response.getOutputStream();

                byte[] buffer = new byte[4096];
                int bytesRead = -1;

                while ((bytesRead = inStream.read(buffer)) != -1) {
                    outStream.write(buffer, 0, bytesRead);
                }

                inStream.close();
                outStream.close();
            } else {
                out.println("<h2>Erro: Arquivo de backup não encontrado!</h2>");
                out.println("<a href='index.jsp' class='btn'>Voltar ao Menu</a>");
            }
        } else {
            out.println("<h2>Erro ao fazer backup!</h2>");
            out.println("<a href='index.jsp' class='btn'>Voltar ao Menu</a>");
        }
    } catch (Exception e) {
        out.println("<h2>Erro: " + e.getMessage() + "</h2>");
        out.println("<a href='index.jsp' class='btn'>Voltar ao Menu</a>");
    }
%>
