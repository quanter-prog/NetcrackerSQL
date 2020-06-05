/* 
Задание 1. 
Выбрать клиентов, у которых были заказы в июле 1999 года. Упорядочить по коду
клиента. Использовать внутреннее соединение (inner join) и distinct.
*/

select  distinct
        c.*
  from  customers c
        join orders o on
          o.customer_id = c.customer_id
        where date'1999-07-01' <= o.order_date and o.order_date < date'1999-08-01'
  order by c.customer_id
;

/*
Задание 2. 
Выбрать всех клиентов и сумму их заказов за 2000 год, упорядочив их по сумме заказов
(клиенты, у которых вообще не было заказов за 2000 год, вывести в конце), затем по ID
заказчика. Вывести поля: код заказчика, имя заказчика (фамилия + имя через пробел),
сумма заказов за 2000 год. Использовать внешнее соединение (left join) таблицы
заказчиков с подзапросом для выбора суммы товаров (по таблице заказов) по клиентам
за 2000 год (подзапрос с группировкой).
*/

select  c.customer_id,
        c.cust_last_name || ' ' || c.cust_first_name as cust_name,
        ord_sum.order_total
  from  customers c
        left join (
          select  o.customer_id,
                  sum(o.order_total) as order_total
            from  orders o
            where date'2000-01-01' <= o.order_date and o.order_date < date'2001-01-01'
            group by  o.customer_id
        ) ord_sum on
          ord_sum.customer_id = c.customer_id
  order by  ord_sum.order_total desc nulls last,
            c.customer_id
;

/*
Задание 3. 
Выбрать сотрудников, которые работают на первой своей должности (нет записей в
истории). Использовать внешнее соединение (какое конкретно?) с таблицей истории, а
затем отбор записей из таблицы сотрудников таких, для которых не «подцепилось»
строк из таблицы истории. Упорядочить отобранных сотрудников по дате приема на
работу (в обратном порядке, затем по коду сотрудника (в обычном порядке).
*/

select  e.*
  from  employees e
        left join job_history jh on
          jh.employee_id = e.employee_id
  where jh.employee_id is null
  order by  e.hire_date desc,
            e.employee_id
;

/* 
Задание 4. 
Выбрать все склады, упорядочив их по количеству номенклатуры товаров,
представленных в них. Вывести поля: код склада, название склада, количество
различных товаров на складе. Упорядочить по количеству номенклатуры товаров на
складе (от большего количества к меньшему), затем по коду склада (в обычном
порядке). Склады, для которых нет информации о товарах на складе, вывести в конце.
Подзапросы не использовать.
*/

select  w.warehouse_id,
        w.warehouse_name,
        count(distinct i.product_id) as products_count
  from  warehouses w
        left join inventories i on
          i.warehouse_id = w.warehouse_id and
          i.quantity_on_hand > 0
  group by  w.warehouse_id,
            w.warehouse_name
  order by  products_count desc nulls last,
            w.warehouse_id
;

/*
Задание 5. 
Выбрать сотрудников, которые работают в США. Упорядочить по коду сотрудника.
*/

select  e.*
  from  employees e
        join  departments d on
          d.department_id = e.department_id
        join  locations l on
          l.location_id = d.location_id and
          l.country_id = 'US'
  order by  e.employee_id
;

/*
Задание 6. 
Выбрать все товары и их описание на русском языке. Вывести поля: код товара,
название товара, цена товара в каталоге (LIST_PRICE), описание товара на русском
языке. Если описания товара на русском языке нет, в поле описания вывести «Нет
описания», воспользовавшись функцией nvl или выражением case (в учебной базе
данных для всех товаров есть описания на русском языке, однако запрос должен быть
написан в предположении, что описания на русском языке может и не быть; для
проверки запроса можно указать код несуществующего языка и проверить, появилось ли
в поле описания соответствующий комментарий). Упорядочить по коду категории
товара, затем по коду товара.
*/

select  pi.product_id,
        pi.product_name,
        pi.list_price,
        nvl(pd.translated_description, 'Нет описания') as ru_description
  from  product_information pi
        left join product_descriptions pd on
          pd.product_id = pi.product_id and
          pd.language_id = 'RU'
  order by  pi.category_id, 
            pi.product_id
;

/*
Задание 7. 
Выбрать товары, которые никогда не продавались. Вывести поля: код товара, название
товара, цена товара в каталоге (LIST_PRICE), название товара на русском языке (запрос
должен быть написан в предположении, что описания товара на русском языке может и
не быть). Упорядочить по цене товара в обратном порядке (товары, для которых не
указана цена, вывести в конце), затем по коду товара.
*/

select  pi.product_id,
        pi.product_name,
        pi.list_price,
        nvl(pd.translated_description, 'Нет описания') as ru_description
  from  product_information pi
        left join order_items oi on
          oi.product_id = pi.product_id 
        left join product_descriptions pd on
          pd.product_id = pi.product_id and
          pd.language_id = 'RU'
  where oi.product_id is null
  order by  pi.list_price desc nulls last,
            pi.product_id
;

/*
Задание 8. 
Выбрать клиентов, у которых есть заказы на сумму больше, чем в 2 раза превышающую
среднюю цену заказа. Вывести поля: код клиента, название клиента (фамилия + имя
через пробел), количество таких заказов, максимальная сумма заказа. Упорядочить по
количеству таких заказов в обратном порядке, затем по коду клиента
*/

select  c.customer_id,
        c.cust_last_name || ' ' || c.cust_first_name as cust_name,
        count(o.order_id) as large_sum_orders_count,
        max(o.order_total) as max_order_sum
  from  customers c
        join orders o on
          o.customer_id = c.customer_id
  where o.order_total > 2 * (
          select  avg(order_total)
            from  orders
        ) 
  group by  c.customer_id,
            c.cust_last_name,
            c.cust_first_name
  order by  large_sum_orders_count desc,
            c.customer_id
;

/*
Задание 9. 
Упорядочить клиентов по сумме заказов за 2000 год. Вывести поля: код клиента, имя
клиента (фамилия + имя через пробел), сумма заказов за 2000 год. Упорядочить данные
по сумме заказов за 2000 год в обратном порядке, затем по коду клиента. Клиенты, у
которых не было заказов в 2000, вывести в конце.
*/

select  c.customer_id,
        c.cust_last_name || ' ' || c.cust_first_name as cust_name,
        sum(o.order_total) as orders_sum
  from  customers c
        left join orders o on
          o.customer_id = c.customer_id and 
          date'2000-01-01' <= o.order_date and o.order_date < date'2001-01-01'
  group by  c.customer_id,
            c.cust_last_name,
            c.cust_first_name
  order by  orders_sum desc nulls last,
            c.customer_id
;

select  c.customer_id,
        c.cust_last_name || ' ' || c.cust_first_name as cust_name,
        o.order_total
  from  customers c
        left join (
          select  o.customer_id,
                  sum(o.order_total) as order_total
            from  orders o
            where date'2000-01-01' <= o.order_date and o.order_date < date'2001-01-01'
            group by  o.customer_id
        ) o on
          o.customer_id = c.customer_id
  order by  o.order_total desc nulls last,
            c.customer_id
;


/*
Задание 10. 
Переписать предыдущий запрос так, чтобы не выводить клиентов, у которых вообще не
было заказов.
*/

select  c.customer_id,
        c.cust_last_name || ' ' || c.cust_first_name as cust_name,
        sum(o.order_total) as orders_sum
  from  customers c
        join orders o on
          o.customer_id = c.customer_id  
  where date'2000-01-01' <= o.order_date and o.order_date < date'2001-01-01'
  group by  c.customer_id,
            c.cust_last_name,
            c.cust_first_name
  order by  orders_sum desc nulls last,
            c.customer_id
;

select  c.customer_id,
        c.cust_last_name || ' ' || c.cust_first_name as cust_name,
        o.order_total
  from  customers c
        join (
          select  o.customer_id,
                  sum(o.order_total) as order_total
            from  orders o
            where date'2000-01-01' <= o.order_date and o.order_date < date'2001-01-01'
            group by  o.customer_id
        ) o on
          o.customer_id = c.customer_id
  order by  o.order_total desc nulls last,
            c.customer_id
;

/*
Задание 11. 
Каждому менеджеру по продажам сопоставить последний его заказ. Менеджера по
продажам считаем сотрудников, код должности которых: «SA_MAN» и «SA_REP».
Вывести поля: код менеджера, имя менеджера (фамилия + имя через пробел), код
клиента, имя клиента (фамилия + имя через пробел), дата заказа, сумма заказа,
количество различных позиций в заказе. Упорядочить данные по дате заказа в обратном
порядке, затем по сумме заказа в обратном порядке, затем по коду сотрудника. Тех
менеджеров, у которых нет заказов, вывести в конце.
*/

select  e.employee_id,
        e.last_name || ' ' || e.first_name as manager_name,
        c.customer_id,
        c.cust_last_name || ' ' || c.cust_first_name as cust_name,
        last_order.order_date,
        o.order_total,
        oi.lines
  from  employees e
        left join (
          select  max(o.order_date) as order_date,
                  o.sales_rep_id
            from  orders o 
            group by  o.sales_rep_id
        ) last_order on 
          last_order.sales_rep_id = e.employee_id
        left join orders o on
          o.sales_rep_id = last_order.sales_rep_id and
          o.order_date = last_order.order_date
        left join customers c on
          c.customer_id = o.customer_id
        left join (
          select  count(oi.line_item_id) as lines,
                  oi.order_id
            from  order_items oi
            group by  oi.order_id
        ) oi on
          oi.order_id = o.order_id
  where e.job_id in ('SA_MAN', 'SA_REP')
  order by  o.order_date desc nulls last,
            o.order_total desc nulls last,
            e.employee_id 
;

/*
Задание 12. 
Проверить, были ли заказы, в которых товары поставлялись со скидкой. Считаем, что
скидка была, если сумма заказа меньше суммы стоимости всех позиций в заказе, если
цены товаров смотреть в каталоге (прайсе). Если такие заказы были, то вывести
максимальный процент скидки среди всех таких заказов, округленный до 2 знаков после
запятой.
*/

select  max(
          round(
            (oi.real_price - o.order_total) / oi.real_price * 100,
            2
          )
        ) as max_discount_percent
  from  orders o
        join (
          select  sum(p.list_price * oi.quantity) as real_price, 
                  oi.order_id
            from  order_items oi
                  join product_information p on
                    p.product_id = oi.product_id
            group by  oi.order_id
        ) oi on
          oi.order_id = o.order_id
;

/*
Задание 13. 
Выбрать товары, которые есть только на одном складе. Вывести поля: код товара,
название товара, цена товара по каталогу (LIST_PRICE), код и название склада, на
котором есть данный товар, страна, в которой находится данный склад. Упорядочить
данные по названию стране, затем по коду склада, затем по названию товара.
*/

select  pi.product_id,
        pi.product_name,
        pi.list_price,
        w.warehouse_id,
        w.warehouse_name,
        con.country_name
  from  product_information pi
        join (
          select  inv.product_id,
                  count(inv.warehouse_id) as warehouse_count,
                  min(inv.warehouse_id) as warehouse_id
            from  inventories inv
            group by inv.product_id
        ) one_products on
          one_products.product_id = pi.product_id and
          one_products.warehouse_count = 1
        join warehouses w on
          w.warehouse_id = one_products.warehouse_id
        join locations l on
          l.location_id = w.location_id
        join countries con on 
          con.country_id = l.country_id
  order by  con.country_name,
            w.warehouse_id,
            pi.product_name
;

/*
Задание 14. 
Для всех стран вывести количество клиентов, которые находятся в данной стране.
Вывести поля: код страны, название страны, количество клиентов. Для стран, в которых
нет клиентов, в качестве количества клиентов вывести 0. Упорядочить по количеству
клиентов в обратном порядке, затем по названию страны.
*/

select  con.country_id,
        con.country_name,
        nvl(cus.customers_count, 0) as customers_count
  from  countries con
        left join (
          select  cus.cust_address_country_id,
                  count(cus.customer_id) as customers_count
            from  customers cus
            group by  cus.cust_address_country_id
        ) cus on
          cus.cust_address_country_id = con.country_id
  order by  customers_count desc,
            con.country_name
;

/*
Задание 15. 
Для каждого клиента выбрать минимальный интервал (количество дней) между его
заказами. Интервал между заказами считать как разницу в днях между датами 2-х
заказов без учета времени заказа. Вывести поля: код клиента, имя клиента
(фамилия + имя через пробел), даты заказов с минимальным интервалом (время не
отбрасывать), интервал в днях между этими заказами. Если у клиента заказов нет или
заказ один за всю историю, то таких клиентов не выводить. Упорядочить по коду
клиента
*/

select  c.customer_id,
        c.cust_last_name || ' ' || c.cust_first_name as cust_name,
        o.order_date1,
        o.order_date2,
        o.min_orders_inerval
  from  customers c
        join (
          select  trunc(o2.order_date) - trunc(o1.order_date) as min_orders_inerval,
                  o1.order_date as order_date1,
                  o2.order_date as order_date2,
                  o1.customer_id
            from  orders o1
                  join orders o2 on
                    o2.customer_id = o1.customer_id and 
                    o2.order_date > o1.order_date
                  join (
                    select  o4.customer_id,
                            min(o4.order_date - o3.order_date) min_date
                      from  orders o3
                            join orders o4 on
                              o4.customer_id = o3.customer_id and 
                              o4.order_date > o3.order_date
                      group by o4.customer_id
                  ) interval_order on 
                    interval_order.customer_id = o2.customer_id and
                    min_date = o2.order_date - o1.order_date
        ) o on
          o.customer_id = c.customer_id
  order by  c.customer_id
;
