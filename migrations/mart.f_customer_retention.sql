insert into mart.f_customer_retention (new_customers_count, returning_customers_count, refunded_customer_count, period_name, period_id, item_id, new_customers_revenue, returning_customers_revenue, customers_refunded)
select count(distinct case when uol.quantity = 1 then uol.customer_id else null end) as new_customers_count, --кол-во новых клиентов (тех, которые сделали только один заказ за рассматриваемый промежуток времени)
	count(distinct case when uol.quantity > 1 then uol.customer_id else null end) as returning_customers_count, --кол-во вернувшихся клиентов (тех, которые сделали только несколько заказов за рассматриваемый промежуток времени)
	sum(case when uol.status = 'refunded' then 1 else 0 end) as refunded_customer_count, --кол-во клиентов, оформивших возврат за рассматриваемый промежуток времени.
	--dc.month_name_abbreviated as period_name, --weekly
	--dc.week_of_year as period_id, --идентификатор периода (номер недели или номер месяца)
	dc.week_of_year as period_name, --weekly
	dc.month_actual as period_id,--идентификатор периода (номер недели или номер месяца)
	uol.item_id as item_id, --идентификатор категории товара
	sum(case when uol.quantity = 1 then uol.payment_amount else 0 end) as new_customers_revenue, --доход с новых клиентов
	sum(case when uol.quantity > 1 then uol.payment_amount else 0 end) as returning_customers_revenue, --доход с вернувшихся клиентов
	sum(case when uol.status = 'refunded' then uol.payment_amount else 0 end) as customers_refunded --количество возвратов клиентов
from staging.user_order_log uol 
left join mart.d_calendar dc on uol.date_time::date = dc.date_actual
group by dc.week_of_year,
		 dc.month_actual,
	     uol.item_id;