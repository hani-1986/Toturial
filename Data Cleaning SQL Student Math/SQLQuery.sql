/*

Cleaning Data in SQL Queries

*/


select *
From SQLToturial.dbo.student_math
--Populate absences Data
select *
From SQLToturial.dbo.student_math
Where absences is null

Update SQLToturial.dbo.student_math
Set absences=0
Where student_id=6

--Populate Grade Data
select *
From SQLToturial.dbo.student_math
where grade_1 is null


Update SQLToturial.dbo.student_math
Set grade_1=12
Where student_id=12

-- Change primary education (4th grade) To primary education 

select father_education,Count(father_education)
From SQLToturial.dbo.student_math
Group By father_education

Update SQLToturial.dbo.student_math
set father_education='primary education'
where father_education='primary education (4th grade)'

select mother_education,Count(mother_education)
From SQLToturial.dbo.student_math
Group By mother_education

Update SQLToturial.dbo.student_math
set mother_education='primary education'
where mother_education='primary education (4th grade)'


--Change Parent_status becouse Increment Space in Parent_status
select parent_status,Count(parent_status)
From SQLToturial.dbo.student_math
Group By parent_status

Update SQLToturial.dbo.student_math
set parent_status='Living together'
where parent_status='     Living  together'

--Remove Duplicate
with CTEROWNUM As(
select *
 , ROW_NUMBER() Over (
   PARTITION BY sex
               ,age
			   ,address_type
			   ,family_size
			   ,parent_status
			   ,mother_education
			   ,father_education
			   ,mother_job
			   ,father_job
			   ,School_choice_reason
			   ,student_id
			   Order By student_id
			   ) AS ROWNUM
From SQLToturial.dbo.student_math

),
REMOVEDUB AS(
Select * 
From CTEROWNUM
where ROWNUM >1
--order by student_id
)
Delete 
From REMOVEDUB
where ROWNUM > 1


