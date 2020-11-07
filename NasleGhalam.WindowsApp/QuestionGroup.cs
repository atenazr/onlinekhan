﻿using Microsoft.Office.Interop.Excel;
using Microsoft.Office.Interop.Word;
using NasleGhalam.Common;
using NasleGhalam.ServiceLayer.Services;
using NasleGhalam.ViewModels.EducationTree;
using NasleGhalam.ViewModels.Lesson;
using NasleGhalam.ViewModels.Question;
using NasleGhalam.ViewModels.QuestionGroup;
using NasleGhalam.ViewModels.Writer;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NasleGhalam.WindowsApp
{
    public partial class QuestionGroup : Form
    {
        private readonly string FilePath = System.Windows.Forms.Application.StartupPath + "\\content\\";



        private readonly LessonService _lessonService;
        private readonly EducationTreeService _educationTreeService;
        private readonly WriterService _writerService;
        private readonly WebService _webService;

        private List<LessonViewModel> lessons;
        private List<EducationTreeViewModel> educationTrees;
        private List<WriterViewModel> writers;

        private List<string> questionsFileNames;


        public QuestionGroup(LessonService lessonService, EducationTreeService educationTreeService, WebService WebService ,WriterService writerService)
        {
            _lessonService = lessonService;
            _educationTreeService = educationTreeService;
            _webService = WebService;
            _writerService = writerService;
            InitializeComponent();
        }



        private void button2_Click(object sender, EventArgs e)
        {
            DialogResult dr = openFileDialog2.ShowDialog();
            if (dr == DialogResult.OK)
            {
                textBox_excel.Text = openFileDialog2.FileName;
            }
        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            DialogResult dr = openFileDialog1.ShowDialog();
            if (dr == DialogResult.OK)
            {
                textBox_word.Text = openFileDialog1.FileName;
            }
        }

        private void tabPage1_Click(object sender, EventArgs e)
        {

        }

        private void QuestionGroup_Load(object sender, EventArgs e)
        {
            lessons = _lessonService.GetAll().ToList();
            educationTrees = _educationTreeService.GetAll().ToList();
            
            PopulateTreeView();

            
            var bindingSource1 = new BindingSource();
            writers = _writerService.GetAll().ToList();
            bindingSource1.DataSource = writers;

            comboBox2.DataSource = bindingSource1.DataSource;

            comboBox2.DisplayMember = "Name";
            comboBox2.ValueMember = "Id";

        }

        private void PopulateTreeView()
        {
            var tempEducationTree = educationTrees.Where(x => x.ParentEducationTreeId == null).FirstOrDefault();
            TreeNode treeNode = makeTree(tempEducationTree);
            treeView1.Nodes.Add(treeNode);

        }

        private TreeNode makeTree(EducationTreeViewModel node)
        {
            var childList = educationTrees.Where(x => x.ParentEducationTreeId == node.Id);

            if (childList == null)
            {
                return new TreeNode(node.Name + "(" + node.Lookup_EducationTreeState.Value + ")" + "(" + node.Id + ")");
            }
            else
            {
                List<TreeNode> treeNodes = new List<TreeNode>();
                foreach (var child in childList)
                {
                    treeNodes.Add(makeTree(child));
                }
                return new TreeNode(node.Name + "(" + node.Lookup_EducationTreeState.Value + ")" + "(" + node.Id + ")", treeNodes.ToArray());

            }

        }

        private void treeView1_AfterSelect(object sender, TreeViewEventArgs e)
        {
            List<int> educationTreeIds = new List<int>();
            educationTreeIds.Add(Convert.ToInt32(e.Node.Text.Split('(')[2].Replace(')', '\0')));
            foreach (TreeNode node in e.Node.Nodes)
            {
                educationTreeIds.Add(Convert.ToInt32(node.Text.Split('(')[2].Replace(')', '\0')));
            }

            List<LessonViewModel> lessonsList = lessons.Where(x => x.EducationTrees.Any(y => educationTreeIds.Contains(y.Id))).ToList();

            var bindingSource1 = new BindingSource();
            bindingSource1.DataSource = lessonsList;

            comboBox1.DataSource = bindingSource1.DataSource;

            comboBox1.DisplayMember = "Name";
            comboBox1.ValueMember = "Id";

        }

        private void button3_Click(object sender, EventArgs e)
        {
            var returnGuidList = new List<string>();
            var missing = Type.Missing;
            var sourceWordFilename = textBox_word.Text;
            var destWordFilename = FilePath + Guid.NewGuid() + ".docx";

            //save Doc and excel file in temp memory
            File.Copy(sourceWordFilename, destWordFilename);

            // Open a doc file.
            var app = new Microsoft.Office.Interop.Word.Application();
            //app.Visible = true;
            var source = app.Documents.Open(destWordFilename, Visible: true);


            //split question group
            var x = source.Paragraphs.Count;
            var i = 1;
            while (i <= x)
            {

                if (IsQuestionParagraph(source.Paragraphs[i].Range.Text))
                {
                    var target = app.Documents.Add(Visible: true);
                    //تریک درست شدن گزینه ها 
                    source.ActiveWindow.Selection.WholeStory();
                    source.ActiveWindow.Selection.Copy();
                    target.ActiveWindow.Selection.Paste();
                    //target.ActiveWindow.Selection.PasteSpecial(Microsoft.Office.Interop.Word.WdPasteOptions.wdKeepTextOnly);
                    target.ActiveWindow.Selection.WholeStory();
                    target.ActiveWindow.Selection.Delete();

                    int startOfQuestionIndex = source.Paragraphs[i].Range.Sentences.Parent.Start;

                    i++;

                    while (i <= x && !IsQuestionParagraph(source.Paragraphs[i].Range.Text))
                    {
                        i++;
                    }

                    int endOfQuestionIndex = source.Paragraphs[i - 1].Range.Sentences.Parent.End;

                    source.Range(startOfQuestionIndex, endOfQuestionIndex).Select();
                    source.ActiveWindow.Selection.Copy();
                    target.ActiveWindow.Selection.Paste();
                    //target.ActiveWindow.Selection.WholeStory();
                    //target.ActiveWindow.Selection.Paragraphs.ReadingOrder = WdReadingOrder.wdReadingOrderRtl;
                    //target.ActiveWindow.Selection.Paste();

                    var newGuid = Guid.NewGuid();
                    var newEntry = FilePath + $"/questionGroupTemp/{newGuid}";
                    returnGuidList.Add(newEntry);
                    var filename2 = FilePath + $"/questionGroupTemp/{newGuid}";

         target.SaveAs(filename2 + ".pdf", WdSaveFormat.wdFormatPDF);           
                    target.SaveAs(filename2 + ".docx");

                    //while (target.Windows[1].Panes[1].Pages.Count < 0) ;

                    //var bits = target.Windows[1].Panes[1].Pages[1].EnhMetaFileBits;
                    ImageTools.SaveImageOfWordPdf(filename2 + ".pdf", filename2);
                    target.Close(WdSaveOptions.wdDoNotSaveChanges);

                    File.Delete(filename2 + ".pdf");
                }
                else
                {
                    i++;
                }


            }

            source.Close();
            app.Quit();

            File.Delete(destWordFilename);
            /////////////////////////////////

            var msgRes = new ClientMessageResult { MessageType = MessageType.Success };
            if (msgRes.MessageType != MessageType.Success)
            {
                MessageBox.Show(msgRes.Message);
            }
            else
            {
                questionsFileNames = returnGuidList;
                tabControl1.SelectTab(1);

                foreach (Control item in panel1.Controls)
                {
                    panel1.Controls.Remove(item);
                }

                var height = 0;
                foreach (var item in returnGuidList)
                {
                    PictureBox pb = new PictureBox();
                    pb.Image = Image.FromFile(item + ".png");
                    pb.Size = new Size(pb.Image.Width, pb.Image.Height);

                    pb.Top = height  + 30;
                    pb.Left = 50 + 870- pb.Image.Width;
                    height  += pb.Height;
                    pb.BorderStyle = BorderStyle.FixedSingle;
                    panel1.Controls.Add(pb);
                    System.Threading.Tasks.Task.Delay(1000);
                }

            }


        }



        public static bool IsQuestionParagraph(string s)
        {
            var arrayTemp = s.ToCharArray();

            var i = 0;
            while (i < arrayTemp.Length)
            {
                if (arrayTemp[i] == ' ' || arrayTemp[i] == '\n' || arrayTemp[i] == '\r')
                {
                    i++;
                }
                else if (char.IsDigit(arrayTemp[i]))
                {
                    i++;
                    while (char.IsDigit(arrayTemp[i]) && i < arrayTemp.Length)
                    {
                        i++;
                    }
                    if (arrayTemp[i] == '-')
                    {
                        var j = 0;
                        while (j < 14 && i < arrayTemp.Length)
                        {
                            i++;
                            j++;
                        }
                        if (j == 14)
                            return true;
                    }
                    return false;
                }
                else
                {
                    break;
                }
                i++;
            }
            return false;
        }

        private async void button4_Click(object sender, EventArgs e)
        {
            tabControl1.SelectTab(2);
            progressBar1.Maximum = questionsFileNames.Count;
            progressBar1.Step = 1;
            progressBar1.Value = 0;
            backgroundWorker1.RunWorkerAsync();
        }

        private async void backgroundWorker1_DoWork(object sender, DoWorkEventArgs e)
        {
            try
            {
                if (textBox_title.Text != "" && textBox_word.Text != "" && textBox_excel.Text != "" && comboBox1.Text != "")
                {

                    var questionGroup = new QuestionGroupCreateViewModel();
                    questionGroup.Title = textBox_title.Text;
                    questionGroup.LessonId = Convert.ToInt32(comboBox1.SelectedValue);
                    questionGroup.QuestionGroupWordPath = textBox_word.Text;
                    questionGroup.QuestionGroupExcelPath = textBox_excel.Text;

                    var result = await _webService.QuestionGrounCreate(questionGroup);

                    if (result.MessageType != MessageType.Success)
                    {
                        MessageBox.Show(result.Message);

                    }
                    else
                    {
                        var missing = Type.Missing;

                        var sourceExecleFilename = textBox_excel.Text;
                        var destExecleFilename = FilePath + Guid.NewGuid() + ".xlsx";
                        File.Copy(sourceExecleFilename, destExecleFilename);
                        //read from excel file
                        var xlApp = new Microsoft.Office.Interop.Excel.Application();
                        var xlWorkbook = xlApp.Workbooks.Open(destExecleFilename, 0, true, 5, "", "", true, XlPlatform.xlWindows, "\t", false, false, 0, true, 1, 0);
                        var xlWorksheet = (_Worksheet)xlWorkbook.Sheets[1];
                        var xlRange = xlWorksheet.UsedRange;

                        var rowCount = xlRange.Rows.Count;
                        var colCount = xlRange.Columns.Count;
                        var dt = new System.Data.DataTable();
                        for (var k = 1; k <= rowCount; k++)
                        {
                            var dr = dt.NewRow();
                            for (var j = 1; j <= colCount; j++)
                            {
                                if (k == 1)
                                {
                                    dt.Columns.Add(Convert.ToString((xlRange.Cells[k, j] as Microsoft.Office.Interop.Excel.Range)?.Value2));
                                }
                                else
                                {
                                    dr[j - 1] = Convert.ToString((xlRange.Cells[k, j] as Microsoft.Office.Interop.Excel.Range)?.Value2);
                                }

                            }
                            if (k != 1)
                                dt.Rows.Add(dr);
                        }

                        xlWorkbook.Close();
                        xlApp.Quit();
                        File.Delete(destExecleFilename);



                        // Open a doc file.
                        var app = new Microsoft.Office.Interop.Word.Application();

                        var numberOfQ = 0;
                        foreach (var questionName in questionsFileNames)
                        {
                            var newQuestionNameFile = Guid.NewGuid();
                            numberOfQ++;
                            var source = app.Documents.Open(questionName + ".docx");

                            QuestionCreateViewModel question = new QuestionCreateViewModel();

                            //حذف عدد اول سوال
                            if (QuestionGroupService.IsQuestionParagraph(source.Paragraphs[1].Range.Text))
                            {
                                int i = 1;
                                while (i < source.Paragraphs[1].Range.Characters.Count &&
                                       source.Paragraphs[1].Range.Characters[i].Text != "-")
                                {
                                    source.Paragraphs[1].Range.Characters[i].Delete();
                                }
                                source.Paragraphs[1].Range.Characters[i].Delete();
                            }

                            foreach (Paragraph paragraph in source.Paragraphs)
                            {
                                question.Context += paragraph.Range.Text;
                            }

                            string filename2 = FilePath + "questionGroupTemp//" + newQuestionNameFile;
                            source.SaveAs(filename2 + ".pdf", WdSaveFormat.wdFormatPDF);
                            source.SaveAs(filename2 + ".docx");
                            ImageTools.SaveImageOfWordPdf(filename2 + ".pdf", filename2);
                            source.Close(WdSaveOptions.wdDoNotSaveChanges);

                            File.Delete(filename2 + ".pdf");

                            question.FilePath = FilePath + "questionGroupTemp//" + newQuestionNameFile;

                            question.LookupId_QuestionType = dt.Rows[numberOfQ - 1]["نوع سوال"].ToString() == "تشریحی" ? 7 : 6;
                            question.QuestionPoint = Convert.ToInt32(dt.Rows[numberOfQ - 1]["بارم سوال"] != DBNull.Value ? dt.Rows[numberOfQ - 1]["بارم سوال"] : 0);
                            question.AnswerNumber = Convert.ToInt32(dt.Rows[numberOfQ - 1]["گزینه صحیح"] != DBNull.Value ? dt.Rows[numberOfQ - 1]["گزینه صحیح"] : 0);
                            question.LookupId_QuestionHardnessType = 1040;
                            //newQuestion.LookupId_AreaType = 1036;
                            question.LookupId_AuthorType = 1039;
                            question.LookupId_RepeatnessType = 21;
                            question.LookupId_QuestionRank = 1063;
                            //newQuestion.Istandard = dt.Rows[numberOfQ - 1]["درجه استاندارد"].ToString() == "استاندارد";
                            question.WriterId = Convert.ToInt32(dt.Rows[numberOfQ - 1]["شماره طراح"] != DBNull.Value ? dt.Rows[numberOfQ - 1]["شماره طراح"] : 1);
                            //newQuestion.Description = dt.Rows[numberOfQ - 1]["توضیحات"].ToString();
                            question.IsActive = false;
                            question.ResponseSecond = Convert.ToInt16(dt.Rows[numberOfQ - 1]["زمان سوال"] != DBNull.Value ? dt.Rows[numberOfQ - 1]["زمان سوال"] : 0);
                            question.UseEvaluation = false;
                            question.QuestionNumber = Convert.ToInt32(dt.Rows[numberOfQ - 1]["شماره سوال در منبع اصلی"] != DBNull.Value ? dt.Rows[numberOfQ - 1]["شماره سوال در منبع اصلی"] : 0);
                            question.SupervisorUserId = Convert.ToInt32(dt.Rows[numberOfQ - 1]["شماره ناظر"] != DBNull.Value ? dt.Rows[numberOfQ - 1]["شماره ناظر"] : 0);

                            question.QuestionGroupId = result.Id;

                            var result2 = await _webService.QuestionCreate(question);

                            if (result2.MessageType != MessageType.Success)
                            {
                                MessageBox.Show(" مشکل در ثبت سوال : \n" + result2.Message);
                                app.Quit();
                                break;
                            }

                            backgroundWorker1.ReportProgress((numberOfQ * 100) / questionsFileNames.Count);




                        }
                        app.Quit();


                    }
                }
                else
                {
                    MessageBox.Show("مقادیر ورودی به صورت کامل وارد نشده اند!");
                }
            }
            catch (Exception error)
            {
                MessageBox.Show(error.Message);
            }
        }

        private void backgroundWorker1_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            progressBar1.Value = e.ProgressPercentage;
        }

        private void backgroundWorker1_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            label5.ForeColor = Color.Green;
            label5.Text = "فایل با موفقیت وارد شد !";
        }

        private void button5_Click(object sender, EventArgs e)
        {
            tabControl1.SelectTab(3);
        }

        private void button6_Click(object sender, EventArgs e)
        {
            DialogResult dr = openFileDialog1.ShowDialog();
            if(dr == DialogResult.OK)
            {
                textBox_wordfileAnswers.Text = openFileDialog1.FileName;
            }
        }

        private void comboBox2_TextChanged(object sender, EventArgs e)
        {
            var bindingSource1 = new BindingSource();
            bindingSource1.DataSource = writers.Where(x => x.Name.StartsWith(comboBox2.Text)).ToList();
            if (bindingSource1.Count != 0)
                comboBox2.DataSource = bindingSource1.DataSource;
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            var bindingSource1 = new BindingSource();
            bindingSource1.DataSource = lessons.Where(x => x.Name.StartsWith(comboBox1.Text)).ToList();
            if (bindingSource1.Count != 0)
                comboBox1.DataSource = bindingSource1.DataSource;
        }
    }
}
