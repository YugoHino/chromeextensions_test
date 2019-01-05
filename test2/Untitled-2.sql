select
	left(rv.item_code, 6) as item_code,
	l1mst.product_name as item_name,
	l1mst.g_dept_id,
	isnull(l1mst.agg_cd, left(rv.item_code, 6)) as agg_cd,
	l1mst.agg_product_name,
	sub.core_category_id,
	sub.core_category_desc,
	rv.comment_id,
	rv.review_comment,
	rv.post_date,
	rv.satisfaction_level,
	rv.referrable no_referrable,
	rv.gender,
	rv.prefecture,
	rv.generation,
	rv.height,
	rv.weight,
	rv.foot_size,
	rv.purchase_size,
	rv.fit,
	ssn.year_ssn
from
	review_file rv,
	subcat_tbl sub,
	(
		select
			ctlg.g_dept_id,
			ctlg.view_product_cd,
			ctlg.product_name,
			l3max.agg_cd,
			l3max.agg_product_name
		from
			catalog ctlg,
			(
				select
					view_product_cd,
					max(l3_product_id) as max_l3_id,
					max(fr_view_ag_cd || fr_aloc_gthr_typ) as agg_cd,
					max(itemlst_local_desc) as agg_product_name
				from
					catalog
					left outer join
						fr_r_sku_dy_itm_hstr
					on	l3_product_id = level3_idnt
				group by
					view_product_cd
			) as l3max
		where
			ctlg.l3_product_id = l3max.max_l3_id
	) l1mst,
	(
		select
			left(view_product_cd, 6) as item_code,
			max(cast((view_year_cd || season) as int)) AS year_ssn
		from
			analyticsdb.analyticspf.catalog
		group by
			1
	) ssn
where
	left(rv.item_code, 6) = sub.level1_idnt
and	left(rv.item_code, 6) = l1mst.view_product_cd
and	left(rv.item_code, 6) = ssn.item_code
and	rv.post_date >= CURRENT_DATE - 120
and	rv.option3 = 'UQ'
and	rv.status = '公開'
and     LEFT(ssn.year_ssn,1) IN (8,9)