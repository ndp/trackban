== Vision & Goals

Scrolling up and down to see a timeline of a project.
The project is divided into epochs: past, present, future (and undefined ?).

Even less intrusive UX than Pivotal Tracker.

Somewhat flexible workflow.

Each story belongs to a theme.

All stores are rank ordered.

Stories can be tagged, and then filtered by tag.

Milestones can be inserted between any two stories.

Stories grouped by theme, user, or ?

Filter out/focus on stories by user, theme, epoch, tag.

Scrolling into the past gives tools appropriate to the past, and into the future, appropriate for the future.
For example, scrolling into the past should facilitate retrospectives-- timelines, 5 whys analysis, etc.

Structure code to accept modules tools based on the epoch.

Learn angular.js and MongoDB

=== Grouping

Stories may be grouped (possible views)

Themes

Stories

Themes > Stories

Milestones > Stories

Milestones > Themes > Stories

Themes > Milestones > Stories

Epochs > Themes

Epochs > Stories

Epochs > Themes > Stories

Epochs > Milestones > Stories

Epochs > Milestones > Themes > Stories

Epochs > Themes > Milestones > Stories

Also Group by
Tag
Worker
Estimate
State

group(stories) => [{group: 'story', values[{},{}]}]
group(stories, :theme) => [{group: 'theme', values[{group: 'story', values: [{},{}]}]

group(stories, :epoch, :milestone) => [{group: epoch, epoch: past, values[...]}, )


