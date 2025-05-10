<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    // Finaliza a sessão do usuário atual
    session.invalidate();

    // Redireciona para a página de login
    response.sendRedirect("login.jsp");
%>
