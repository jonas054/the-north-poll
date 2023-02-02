# The North Poll

The North Poll is an online voting app designed for teams that want to
vote on issues quickly and without hassle.

The original use case was [OKR](https://en.wikipedia.org/wiki/OKR)
confidence levels.

![image](https://user-images.githubusercontent.com/336720/135056201-a93c5e8c-1c51-4c97-b2c7-74aa4802e50c.png)

## Features

##### A number of preset scales to choose from

By _scale_, we mean the choices available in a vote, for examples the
numbers 1 through 10, the Fibonacci series used for
[planning poker](https://en.wikipedia.org/wiki/Planning_poker), or the
thumbs up, thumbs down, and shrugging icons.

##### Custom scales

It's also possible to define your own scale for a single or series of
poll. Just give them on the creation page with space or semi-colon
between each item.

##### Series of polls

In a series of polls the choices are the same for each poll. A combined result
is presented at the end.

##### Live editing of poll titles

The creator of a poll is directed to a page with links after the poll is
created. One link goes to the poll and includes editing privileges, another
link goes to the same page but without privileges. The second link is for
distribution to participants.

##### Calculation of averages and standard deviation

When all choices are numeric, average and standard deviation is presented on
the result pages.

## Exmaple usage, planning poker

There are a few features built in to the app for supporting the so-called
planning poker sessions that are typically part of refinement meetings
in agile development methodologies. Here's a sequence of actions to
showcase these features.

The landing page for the app is at https://the-north-poll.herokuapp.com/
where the following is shown:

![Landing](https://user-images.githubusercontent.com/336720/216357539-eeae926a-24c9-439b-892a-adc53b2ae75f.png)

You can click on the compass icon on any page to come here. Click on Create new poll.

![Creation](https://user-images.githubusercontent.com/336720/216358313-2de7ef59-3e38-4441-9897-24b42f463437.png)

Here you can choose the title and the scale for your polls. If you choose a scale without having entered a
title, a default alphabetical series of titles will be filled-in for you.

![Alphabet series](https://user-images.githubusercontent.com/336720/216358859-99c1dc84-7485-4018-bc0c-23d7203d2959.png)

Scroll down to find the Create new poll button.

![Creation button](https://user-images.githubusercontent.com/336720/216359142-f76db4b9-c1c8-494e-a512-2e9d8892ed60.png)

After creating the series, you come to the listing page. The URL of this page is what you distribute to the team.
That link can be reused for every meeting where you want to vote using the chosen scale.

The top link "A" goes to the first poll in the series. It includes editing privileges so that the person who
followed that link can update the titles during the meeting to something more meaningful than A, B, C, etc.

![First poll in edit mode](https://user-images.githubusercontent.com/336720/216360187-a3c30939-ea39-43f7-91dd-3a1f0b525967.png)

When the Rename button is clicked, all team members looking at the same poll will see the updated title. This
goes for links as well.

At the bottom of the page for the first poll in the series, there's a QR code and a numerical code for
finding this page in other ways (not through a distributed URL). The QR code should be scanned on a phone device,
and the numerical code can be entered on the landing page.

Now the voting takes place, and each participant can see the current result after their vote. The diagram is
updated live until no more votes are cast.

![Results](https://user-images.githubusercontent.com/336720/216361521-ee0f8d47-8e63-4822-a40b-458564ae59bb.png)
