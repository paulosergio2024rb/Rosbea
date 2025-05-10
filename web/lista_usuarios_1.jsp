<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>

<%-- (Seu código da classe Usuario e conexão com o banco de dados permanece o mesmo) --%>
<%!
    class Usuario {
        private int id;
        private String nomeUsuario;

        public Usuario(int id, String nomeUsuario) {
            this.id = id;
            this.nomeUsuario = nomeUsuario;
        }

        public int getId() {
            return id;
        }

        public String getNomeUsuario() {
            return nomeUsuario;
        }
    }
%>
<%
    String dbURL = "jdbc:mariadb://localhost:3306/Rosbea";
    String dbUser = "paulo";
    String dbPassword = "6421";
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    List<Usuario> listaDeUsuarios = new ArrayList<>();
    String mensagemErro = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        String sql = "SELECT id, nome_usuario FROM usuarios";
        stmt = conn.createStatement();
        rs = stmt.executeQuery(sql);
        while (rs.next()) {
            int id = rs.getInt("id");
            String nome = rs.getString("nome_usuario");
            listaDeUsuarios.add(new Usuario(id, nome));
        }
    } catch (SQLException e) {
        mensagemErro = "Erro ao acessar o banco de dados: " + e.getMessage();
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        mensagemErro = "Driver do banco de dados não encontrado: " + e.getMessage();
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lista de Usuários</title>
    <style>
        /* (Seus estilos CSS permanecem os mesmos) */
        body {
            font-family: sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }

        .container {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 80%;
            max-width: 800px;
        }

        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }

        th {
            background-color: #f2f2f2;
            font-weight: bold;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .actions a {
            margin-right: 10px;
            text-decoration: none;
            color: #007bff;
        }

        .actions a:hover {
            text-decoration: underline;
        }

        .actions button {
            background-color: #dc3545;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }

        .actions button:hover {
            background-color: #c82333;
        }

        .erro {
            color: red;
            font-weight: bold;
            margin-top: 10px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Lista de Usuários</h1>

        <% if (mensagemErro != null) { %>
            <p class="erro"><%= mensagemErro %></p>
        <% } else if (listaDeUsuarios.isEmpty()) { %>
            <p>Nenhum usuário cadastrado.</p>
        <% } else { %>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nome de Usuário</th>
                        <th>Ações</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Usuario usuario : listaDeUsuarios) { %>
                        <tr>
                            <td><%= usuario.getId() %></td>
                            <td><%= usuario.getNomeUsuario() %></td>
                            <td class="actions">
                                <a href="editar_usuario.jsp?id=<%= usuario.getId() %>">Editar</a>
                                <form action="excluir_usuario.jsp" method="post" style="display: inline;">
                                    <input type="hidden" name="id" value="<%= usuario.getId() %>">
                                    <button type="submit" onclick="return confirm('Tem certeza que deseja excluir este usuário?')">Excluir</button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>
</body>
<footer>
    <a href="painel_admin.jsp"></i> Voltar</a>
</footer>
</html>