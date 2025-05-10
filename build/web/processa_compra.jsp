<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Processamento da Compra</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>Processamento da Compra</h1>

<%
    // Configuração do banco de dados
    String url = "jdbc:mariadb://localhost:3306/Rosbea";
    String usuario = "paulo";
    String senha = "6421";
    Connection connection = null;
    PreparedStatement pstmtCompra = null;
    PreparedStatement pstmtItem = null;

    try {
        // Carregar driver e conectar
        Class.forName("org.mariadb.jdbc.Driver");
        connection = DriverManager.getConnection(url, usuario, senha);
        connection.setAutoCommit(false);

        // Parâmetros do formulário
        String fornecedor = request.getParameter("fornecedor");
        String dataPedido = request.getParameter("data_pedido");
        String cotacaoDolarStr = request.getParameter("cotacao_dolar");
        double cotacaoDolar = (cotacaoDolarStr != null && !cotacaoDolarStr.isEmpty()) ?
                                    Double.parseDouble(cotacaoDolarStr) : 5.0;

        if (fornecedor == null || fornecedor.isEmpty() || dataPedido == null || dataPedido.isEmpty()) {
            throw new Exception("Fornecedor e data do pedido são obrigatórios");
        }

        // Inserir compra
        String sqlCompra = "INSERT INTO compra (fornecedor, data_pedido) VALUES (?, ?)";
        pstmtCompra = connection.prepareStatement(sqlCompra, Statement.RETURN_GENERATED_KEYS);
        pstmtCompra.setString(1, fornecedor);
        pstmtCompra.setString(2, dataPedido);

        int compraInserida = pstmtCompra.executeUpdate();
        int idCompra = -1;

        if (compraInserida > 0) {
            ResultSet generatedKeys = pstmtCompra.getGeneratedKeys();
            if (generatedKeys.next()) {
                idCompra = generatedKeys.getInt(1);
            }
        }

        // Dados dos itens da compra
        String[] produtosIds = request.getParameterValues("produto[]");
        String[] quantidades = request.getParameterValues("quantidade_compra[]");
        String[] precos = request.getParameterValues("preco[]");
        String[] precosDolar = request.getParameterValues("precodolar[]");
        String[] mls = request.getParameterValues("ml_compra[]");
        String[] embalagens = request.getParameterValues("embalagem[]");

        if (produtosIds != null && produtosIds.length > 0) {
            String sqlItem = "INSERT INTO compra_item (pedido_id, produto_id, quantidade_compra, preco, precodolar, preco_dolar_real, total_entrada, ml_compra, embalagem) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmtItem = connection.prepareStatement(sqlItem);

            for (int i = 0; i < produtosIds.length; i++) {
                try {
                    int produtoId = Integer.parseInt(produtosIds[i]);
                    int quantidade = Integer.parseInt(quantidades[i]);
                    double preco = Double.parseDouble(precos[i]);
                    double precoDolar = (precosDolar != null && i < precosDolar.length && precosDolar[i] != null && !precosDolar[i].isEmpty())
                            ? Double.parseDouble(precosDolar[i]) : 0.0;
                    double precoDolarReal = precoDolar * cotacaoDolar;
                    double totalItem = quantidade * preco;
                    double mlCompra = (mls != null && i < mls.length && mls[i] != null && !mls[i].isEmpty())
                            ? Double.parseDouble(mls[i]) : 0.0;
                    int embalagemInt = 0; // Valor padrão
                    if (embalagens != null && i < embalagens.length && embalagens[i] != null && !embalagens[i].isEmpty()) {
                        try {
                            embalagemInt = Integer.parseInt(embalagens[i]);
                        } catch (NumberFormatException e) {
                            out.println("<p class='error'>Erro ao processar embalagem do item " + (i+1) + ": valor inválido para inteiro. Usando 0.</p>");
                            embalagemInt = 0;
                        }
                    }

                    pstmtItem.setInt(1, idCompra);
                    pstmtItem.setInt(2, produtoId);
                    pstmtItem.setInt(3, quantidade);
                    pstmtItem.setDouble(4, preco);
                    pstmtItem.setDouble(5, precoDolar);
                    pstmtItem.setDouble(6, precoDolarReal);
                    pstmtItem.setDouble(7, totalItem);
                    pstmtItem.setDouble(8, mlCompra);
                    pstmtItem.setInt(9, embalagemInt); // Agora inserindo um inteiro

                    pstmtItem.executeUpdate();
                } catch (NumberFormatException e) {
                    out.println("<p class='error'>Erro ao processar item " + (i+1) + ": valores inválidos.</p>");
                }
            }
        }

        connection.commit();
        out.println("<p class='success'>Compra registrada com sucesso! ID da Compra: " + idCompra + "</p>");

    } catch (ClassNotFoundException e) {
        out.println("<p class='error'>Erro ao carregar o driver JDBC: " + e.getMessage() + "</p>");
        if (connection != null) {
            try { connection.rollback(); } catch (SQLException ex) { out.println("<p class='error'>Erro no rollback: " + ex.getMessage() + "</p>"); }
        }
    } catch (SQLException e) {
        out.println("<p class='error'>Erro de SQL: " + e.getMessage() + "</p>");
        if (connection != null) {
            try { connection.rollback(); } catch (SQLException ex) { out.println("<p class='error'>Erro no rollback: " + ex.getMessage() + "</p>"); }
        }
    } catch (Exception e) {
        out.println("<p class='error'>Erro: " + e.getMessage() + "</p>");
        if (connection != null) {
            try { connection.rollback(); } catch (SQLException ex) { out.println("<p class='error'>Erro no rollback: " + ex.getMessage() + "</p>"); }
        }
    } finally {
        try { if (pstmtItem != null) pstmtItem.close(); } catch (SQLException e) {}
        try { if (pstmtCompra != null) pstmtCompra.close(); } catch (SQLException e) {}
        try { if (connection != null) connection.close(); } catch (SQLException e) {}
    }
%>

    <p><a href="compra_form.html">Voltar ao formulário</a></p>
</body>
</html>