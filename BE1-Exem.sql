--phan 1
--1
create table Customer(
    customer_id varchar(5),
    customer_full_name varchar(100)not null ,
    customer_email varchar(100) unique not null ,
    customer_phone varchar(15) not null ,
    customer_address varchar(255) not null ,

    primary key (customer_id)

);

create table Room(
    room_id varchar(5),
    room_type varchar(50) not null ,
    room_price numeric(10,2) not null ,
    room_status varchar(20) not null check (room_status in ('Available', 'Booked', 'Maintance')),
    room_area int not null ,

    primary key (room_id)
);

create table Booking(
    booking_id serial,
    customer_id varchar(5),
    room_id varchar(5),
    check_in_date date not null ,
    check_out_date date not null ,
    total_amount decimal(10 ,2 ),

    primary key (booking_id),
    foreign key (customer_id) references Customer(customer_id),
    foreign key (room_id) references  Room(room_id)
);


create table Payment(
    payment_id serial,
    booking_id int,
    payment_method varchar(50) not null ,
    payment_date date not null ,
    payment_amount decimal(10 ,2) not null ,

    primary key (payment_id),
    foreign key (booking_id) references Booking(booking_id)
);

--2
insert into Customer(customer_id, customer_full_name, customer_email, customer_phone, customer_address)
values ('C001', 'Nguyen Anh Tu', 'tu.nguyen@example.com', '0912345678', 'Hanoi, Vietnam'),
       ('C002', 'Tran Thi Mai', 'mai.tran@example.com', '0923456789','Ho Chi Minh, Vietnam'),
       ('C003', 'Le Minh Hoang', 'hoang.le@example.com', '0934567890', 'Danang, Vietnam'),
       ('C004', 'Pham Hoang Nam', 'nam.pham@example.com', '0945678901','Hue, Vietnam'),
       ('C005', 'Vu Minh Thu', 'thu.vu@example.com', '0956789012', 'Hai Phong, Vietnam');


insert into Room(room_id, room_type, room_price, room_status, room_area)
values ('R001', 'Single', 100.0,'Available', 25),
       ('R002', 'Double', 150.0,'Booked', 40),
       ('R003', 'Suite', 250.0,'Available', 60),
       ('R004', 'Single', 120.0,'Booked', 30),
       ('R005', 'Double', 160.0,'Available', 35);


insert into Booking(customer_id, room_id, check_in_date, check_out_date, total_amount)
values ('C001', 'R001' , '2025-03-01', '2025-03-05', 400.0),
       ('C002', 'R002' , '2025-03-02', '2025-03-06', 600.0),
       ('C003', 'R003' , '2025-03-03', '2025-03-07', 1000.0),
       ('C004', 'R004' , '2025-03-04', '2025-03-08', 480.0),
       ('C005', 'R005' , '2025-03-05', '2025-03-09', 800.0);


insert into Payment(booking_id, payment_method, payment_date, payment_amount)
values ( 1, 'Cash', '2025-03-05', 400.0),
       ( 2, 'Credit Card', '2025-03-06', 600.0),
       ( 3, 'Bank Transfer', '2025-03-07', 1000.0),
       ( 4, 'Cash', '2025-03-08', 480.0),
       ( 5, 'Credit Card', '2025-03-09', 800.0);

--3
update Booking as b
set total_amount = r.room_price*(b.check_out_date - b.check_in_date)
from Room as r
where b.room_id = r.room_id
    and r.room_status = 'Booked'
    and b.check_in_date < current_date;

--4
delete from Payment where payment_method = 'Cash' and payment_amount < 500;


--phan 2
--5
select c.customer_id, c.customer_full_name, c.customer_phone, c.customer_email, c.customer_address
from Customer as c
order by c.customer_full_name asc ;
--6
select r.room_id, r.room_type, r.room_price, r.room_area
from Room as r
order by r.room_price desc ;

--7
select c.customer_id, c.customer_full_name, b.room_id, b.check_in_date, b.check_out_date
from Booking b
join Customer c on c.customer_id = b.customer_id;

--8
select c.customer_id, c.customer_full_name, P.payment_amount, p.payment_method
from Customer as c
join Booking b on c.customer_id = b.customer_id
join Payment P on b.booking_id = P.booking_id
order by p.payment_amount desc ;

--9
select *
from Customer
order by customer_full_name
offset 1
limit 3;

--10
select c.customer_id, c.customer_full_name, count(distinct b.room_id) as "sl_phong", sum(P.payment_amount) as "tong-tien"
from Customer c
join Booking B on c.customer_id = B.customer_id
join Payment P on B.booking_id = P.booking_id
group by c.customer_id, c.customer_full_name
having count(b.room_id) >= 2 and sum(P.payment_amount) > 1000;

--11
select b.room_id, r.room_type, r.room_price, sum(p.payment_amount) as "tong_tien", count(distinct b.customer_id) as "so_khach_dat"
from Booking as b
join Room r on r.room_id = b.room_id
join Payment p on b.booking_id = p.booking_id
group by r.room_type, b.room_id, r.room_price
having sum(p.payment_amount) < 1000 and count(distinct b.customer_id) >= 3;

--12
select c.customer_id, c.customer_full_name, b.room_id, sum(p.payment_amount) as "tong_tien"
from Customer c
join Booking B on c.customer_id = B.customer_id
join Payment P on B.booking_id = P.booking_id
group by c.customer_id, c.customer_full_name, b.room_id
having sum(p.payment_amount) > 1000;

--13
select c.customer_id, c.customer_full_name, c.customer_email, c.customer_phone, c.customer_address
from Customer c
where c.customer_full_name ilike '%Minh%' or c.customer_address ilike '%Hanoi%'
order by c.customer_full_name asc ;

--14
select r.room_id, r.room_type, r.room_price
from Room as r
order by r.room_price desc
offset 5
limit 5;

--phan 3

--15

create view v_booking_before03101025 as
    select r.room_id, r.room_type, c.customer_id, c.customer_full_name
    from Booking b
    join Room r on r.room_id = b.room_id
    join Customer c on c.customer_id = b.customer_id
    where b.check_in_date < date '2025-03-10';

--16
create view v_booking_areaover30m2 as
    select c.customer_id, c.customer_full_name, r.room_id, r.room_area
    from Booking b
    join Room R on R.room_id = b.room_id
    join Customer C on C.customer_id = b.customer_id
    where r.room_area > 30;

--phan 4

--17
create or replace function funcion_check_insert_booking()
returns trigger
language plpgsql
as $$
    begin
        if new.check_in_date > new.check_out_date then
            raise exception 'Ngày đặt phòng không thể sau ngày trả phòng được !';
        end if;

        return new;
    end;
    $$;

create trigger  check_insert_booking
before insert on Booking
for each row
execute function funcion_check_insert_booking();


insert into Booking(customer_id, room_id, check_in_date, check_out_date, total_amount)
values ('C002', 'R003', '2025-10-10', '1025-01-01', 363636);


-- 18

create or replace function function_update_room_status_on_booking()
returns trigger
language plpgsql
as $$
    begin
        update Room
        set room_status = 'Booked'
        where room_id = new.room_id;

        return new;
    end;
    $$;

create trigger update_room_status_on_booking
after insert on Booking
for each row
execute function function_update_room_status_on_booking();


insert into Booking(customer_id, room_id, check_in_date, check_out_date, total_amount)
values ('C003', 'R005', '2025-03-06', '2025-06-03', 363663);

--phan 5

-- 19

create or replace procedure add_customer(in p_customer_id varchar(5), in p_customer_full_name varchar(100), p_customer_email varchar(100), p_customer_phone varchar(15), p_customer_address varchar(255))
language plpgsql
as $$
    begin
        insert into Customer(customer_id, customer_full_name, customer_email, customer_phone, customer_address)
        values (p_customer_id,p_customer_full_name, p_customer_email, p_customer_phone, p_customer_address);
    end;
    $$;

call add_customer('C006', 'Ten Gi Do', '12345@gmail.com', '081273312', 'Thanh Hoa');


--20
create or replace procedure add_payment(in p_booking_id int, in p_payment_method varchar(50), in p_payment_amount numeric(10, 2), in p_payment_date date)
language plpgsql
as $$
    begin
        if not exists(select 1 from Booking where booking_id = p_booking_id) then
            raise exception 'ko tim thay id %', p_booking_id;
        end if;

        insert into Payment(booking_id, payment_method, payment_date, payment_amount)
        values (p_booking_id, p_payment_method, p_payment_date, p_payment_amount);
    end;
    $$;



call add_payment(6, 'Cash',3600.0, '2025-03-10');


