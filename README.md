# Doom Kanban Board

Welcome to **Doom Kanban Board**, a fun and interactive game to manage your tasks using a simple Kanban board inspired by the chaos and strategy of a daily work day! 💀

## How to Play

In Doom Kanban Board, you will manage tasks by moving them through four distinct columns until they are marked as "Done".

### 🛠️ ¿How Doom Kanban Board works?:

1. **To Do**:  
   This is where all your new tasks go. Tasks start here and wait for your attention.

2. **In Progress**:  
   When you start working on a task, move it to this column. This represents the tasks you're actively tackling. Wait until a checkbox appears on the top right corner of the card to mark it as complete allowing you to pass it to the next stage (testing)

3. **Testing**:  
   Once a task is completed, but needs a final check, move it here. It's the "QA" phase where you review or test your work.
   In this phase it is possible that you find bugs that will mark your task with a red flag 🚩
   To fix the bug and remove the flag you must tap on the task and it will open a chat with the developer to fix the issue. Once the conversation is finished, the task will automatically remove its flag and autocomplete.

4. **Done**:  
   Once the testing part is done and the task is complete you can move the task to Done. Congratulations! 🎉
   It's important to know that you must move all the tasks to Done before each of its counters/completion date gets to 0 and you will the remaining time as extra points for your final score.


### 🎮 Rules:

1. **Move tasks** drag and drop all tasks to Done column.
2. **Understand the layout and indicators** 
   - If you fail a task, you will receive a warning ⚠️ from your boss. 3 warnings in the same project and you are fired.
   ![Warning](https://github.com/JLEscolaDev/DoomKanban/tree/assets/warnings.png)
   - You have a layout on your left that will show you the next tasks based on its projects and sprint. It is posible to have multiple projects running (represented by color). Each project have multiple sprints and each sprint has multiple tasks. You have to complete them all.
   ![Sprints](https://github.com/JLEscolaDev/DoomKanban/tree/assets/runningSprints.png)

   - You have a layout on your right with 3 skills. This skills will provide you:
      1. Skill to see the remaining task for the next task to drop on To Do.
      2. Skill to reduce to half the remaining tasks.
      3. Skill to autoComplete faster the tasks (it last some seconds)
   ![Skills](https://github.com/JLEscolaDev/DoomKanban/tree/assets/skills.png)

   - There are tasks marked with a red flag 🚩 that you must fix, a task can be important marked with a red exclamation ❗️ that will give you double points but also double warnings if you fail.
   ![Task](https://github.com/JLEscolaDev/DoomKanban/tree/assets/kanbanTask.png)
3. **How you win?** You dont.
4. **How you lose?** Keep trying to be the best on the leaderboard until you burn out. See? like a real work!:D

Repeat this process to manage your workflow effectively.

## Features

- Interactive drag-and-drop Kanban board
- Four distinct task columns: Backlog, In Progress, Review, and Done.
- Fake mobile chat and pool of task titles based on jokes.
- Office immersive experience that will react to the running game.
![Office in fire](https://github.com/JLEscolaDev/DoomKanban/tree/assets/officeFire.png)
- Leaderboard connected to iCloud and GameCenter
![Leaderboard](https://github.com/JLEscolaDev/DoomKanban/tree/assets/leaderboard.png)
- 3d model representation of Game Center archivements
![Archivements](https://github.com/JLEscolaDev/DoomKanban/tree/assets/archivements.png)

## How to test

To get started, clone the repository and run the app in xcode to test the app.
For a full experience you'll need a Sandbox user that can see the leaderboard and the archivements before publishing the app. 
   - Log in iCloud and GameCenter with this account:
      - User: appleemail4testing@gmail.com
      - Pass: applePass4Testing^
❗ This is really important to be able to save scores, see the leaderboard, load the archivements, etc. 



## License

This project is proprietary and confidential. Unauthorized copying, distribution, modification, or any other use is strictly prohibited. All rights reserved by Jose Luis Escolá García.
