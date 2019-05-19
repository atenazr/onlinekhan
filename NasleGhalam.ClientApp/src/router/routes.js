export default [
  {
    path: "/user/login",
    component: () => import("src/views/user/login.vue")
  },
  {
    path: "/",
    component: () => import("layouts/default.vue"),
    children: [
      // {
      //   path: "",
      //   component: () => import("src/views/test/HelloDecorator/index.vue")
      // },
      {
        path: "",
        component: () => import("src/views/city/index.vue")
      },
      {
        path: "/province",
        component: () => import("src/views/province/index.vue")
      },
      {
        path: "/city",
        component: () => import("src/views/city/index.vue")
      },
      {
        path: "/lesson",
        component: () => import("src/views/lesson/index.vue")
      },
      {
        path: "/role",
        component: () => import("src/views/role/index.vue")
      },
      {
        path: "/user",
        component: () => import("src/views/user/index.vue")
      },
      {
        path: "/educationSubGroup",
        component: () => import("src/views/educationSubGroup/index.vue")
      },
      {
        path: "/topic",
        component: () => import("src/views/topic/index.vue")
      },
      {
        path: "/educationBook",
        component: () => import("src/views/educationBook/index.vue")
      },
      {
        path: "/publisher",
        component: () => import("src/views/publisher/index.vue")
      },
      {
        path: "/tag",
        component: () => import("src/views/tag/index.vue")
      },
      {
        path: "/educationYear",
        component: () => import("src/views/educationYear/index.vue")
      },
      {
        path: "/axillaryBook",
        component: () => import("src/views/axillaryBook/index.vue")
      },
      {
        path: "/question",
        component: () => import("src/views/question/index.vue")
      },
      {
        path: "/student",
        component: () => import("src/views/student/index.vue")
      },
      {
        path: "/educationTree",
        component: () => import("src/views/educationTree/index.vue")
      },
      {
        path: "/questionGroup",
        component: () => import("src/views/questionGroup/index.vue")
      },
      {
        path: "/writer",
        component: () => import("src/views/writer/index.vue")
      },
      {
        path: "/lesson_User",
        component: () => import("src/views/lesson_User/index.vue")
      }
    ]
  },
  {
    // Always leave this as last one
    path: "*",
    component: () => import("pages/404.vue")
  }
];
