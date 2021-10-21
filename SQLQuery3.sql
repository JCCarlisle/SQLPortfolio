


-- Previewing Tables


Select *
-- From [2021TokyoOlympics]..Athletes
-- From [2021TokyoOlympics]..Coaches
-- From [2021TokyoOlympics]..Gender
-- From [2021TokyoOlympics]..Medals
-- From [2021TokyoOlympics]..Teams


-- Cleaning data


-- Converting numeric columns form nvarchar

ALTER TABLE [2021TokyoOlympics]..Gender
ALTER COLUMN Total INT

Alter Table [2021TokyoOlympics]..Gender
alter column Female int

Alter Table [2021TokyoOlympics]..Gender
alter column Male int


-- Exploring tables


-- Number of athletes participating per country/NOC(National Olympic Committee)

Select NOC, Count(Name) as Participants
From [2021TokyoOlympics]..Athletes
Group by NOC
Order by Participants desc


-- number of events competed in by county/NOC

Select NOC, COUNT(Discipline) as 'Count'
From [2021TokyoOlympics]..Teams
Group by NOC
Order by 'Count' desc


-- Total Participants per Event and by Gender

Select *
From [2021TokyoOlympics]..Gender
Order by Total Desc


-- Number of Gold Won by Country/NOC

Select *
From [2021TokyoOlympics]..Medals


-- Exporting Data for Visualization


-- Creating Participant Count Table

Select NOC, Count(Name) as Participants
Into [2021TokyoOlympics]..ParticipantCount
From [2021TokyoOlympics]..Athletes
Group by NOC
Order by Participants desc

