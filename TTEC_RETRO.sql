create or replace FUNCTION TTEC_RETRO(p_person_id IN NUMBER,p_ovn IN NUMBER, p_creation_dt IN DATE) RETURN varchar2 IS
v_return_val varchar2(5);
v_second_max_term_date date := '01-JAN-1951';
v_recent_creation_dates number;
v_initial_creation_date date;
v_initial_term_date date;
v_rev_term_check number;

BEGIN
    select count(1) into v_rev_term_check
    from apps.ttec_kr_emp_terms a
    where person_id = p_person_id
    and source_ovn = p_ovn - 1
    and new_term_date is null;

        begin
        if v_rev_term_check = 1 then
            select count(distinct trunc(creation_date)) into v_recent_creation_dates
            from apps.ttec_kr_emp_terms a
            where person_id = p_person_id
            and source_ovn in (p_ovn, p_ovn - 1);

            if v_recent_creation_dates = 1 then
                select trunc(a.creation_date),trunc(a.new_term_date)
                    into v_initial_creation_date, v_initial_term_date
                from apps.ttec_kr_emp_terms a
                    , (SELECT person_id,source_ovn,creation_date,
                        RANK() OVER (ORDER BY source_ovn,new_term_date) my_rank
                        FROM apps.ttec_kr_emp_terms a
                        where person_id = p_person_id
                        order by my_rank desc) b
                where a.person_id = b.person_id
                and a.creation_date = b.creation_date
                and my_rank = 1;

                if v_initial_creation_date <> v_initial_term_date then
                    return 'T';
                else
                    return 'F';
                end if;
            else
                return 'T';
            end if;
        else
            return 'NR';
        end if;
    exception when others then
        return 'E1';
    end;
exception when others then
    return 'E2';
END TTEC_RETRO;
/
show errors;
/